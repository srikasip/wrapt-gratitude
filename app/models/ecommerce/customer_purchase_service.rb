class CustomerPurchaseService
  include ChargeConstants

  DesiredGift = Struct.new(:gift, :quantity)

  attr_accessor :cart_id, :customer, :desired_gifts, :customer_order,
    :our_charge, :profile, :shipment, :shipping_info, :shipping_label,
    :stripe_charge, :stripe_token

  #delegate :error_message, to: :our_charge, prefix: false

  def initialize(cart_id:, customer: nil, desired_gifts: nil, profile: nil, shipping_info: nil, stripe_token: nil)
    self.cart_id       = cart_id
    self.customer      = customer
    self.desired_gifts = desired_gifts
    self.profile       = profile
    self.shipping_info = shipping_info
    self.stripe_token  = stripe_token
  end

  def generate_order!
    _sanity_check!

    _safely do
      _init_order_and_purchase_orders!
      _init_shipment!
      _init_our_charge_record!
    end

    self.customer_order
  end

  def _init_order_and_purchase_orders!
    self.customer_order = CustomerOrder.where(cart_id: self.cart_id).first_or_initialize

    self.customer_order.assign_attributes({
      user: self.customer,
      profile: self.profile,
      recipient_name: profile.name,
      ship_address_1:  shipping_info[:ship_address_1],
      ship_city:  shipping_info[:ship_city],
      ship_postal_code:  shipping_info[:ship_postal_code],
      ship_region:  shipping_info[:ship_region],
      ship_country:  shipping_info[:ship_country]
    })

    self.customer_order.save!

    self.desired_gifts.each do |dg|
      gift = dg.gift

      purchase_order = PurchaseOrder.
        where(customer_order: self.customer_order).
        where(vendor: gift.vendor).
        first_or_initialize

      purchase_order.save!

    line_item = self.customer_order.
       line_items.
       where(orderable: gift).
       first_or_initialize

     line_item.assign_attributes({
        orderable: gift,
        quantity: dg.quantity,
        price_per_each_in_dollars: gift.price,
        total_price_in_dollars: gift.price * dg.quantity
      })

     line_item.save!

      gift.products.each do |product|
       line_item =  purchase_order.line_items.where(orderable: product).first_or_initialize

       line_item.assign_attributes({
          orderable: product,
          quantity: dg.quantity,
          price_per_each_in_dollars: product.wrapt_cost,
          total_price_in_dollars: product.wrapt_cost * dg.quantity
        })

       line_item.save!
      end
    end
  end

  def _init_shipment!
    self.shipment = Shipment.new
    #WIP
  end

  def _init_our_charge_record!
    if self.stripe_token.blank?
      raise InternalConsistencyError, "You must have a stripe token to even think of charging a card"
    end

    self.our_charge = Charge.where(cart_id: self.cart_id).first_or_initialize
    self.our_charge.assign_attributes({
      token: self.stripe_token,
      state: INITIALIZED,
      amount_in_cents: amount_in_cents,
      description: _description,
      idempotency_key: _idempotency_key,
      idempotency_key_expires_at: (Time.now+1.day),
      metadata: {
        # user_id
        # profile_id
      }
    })
    self.our_charge.save!
  end

  #def auth_and_charge!
  #  authorize!
  #  if auth_success?
  #    charge!
  #  end
  #end

  #def authorize!
  #  _sanity_check!
  #  _init_our_charge_record!
  #
  #  _safely do
  #    _do_stripe_auth!
  #    _verify_consistency!(captured: false)
  #    _save_auth_results!
  #  end
  #
  #  self.our_charge
  #end

  #def charge!
  #  _sanity_check!
  #
  #  _safely do
  #    _do_stripe_charge!
  #    _verify_consistency!(captured: true)
  #    _save_charge_results!
  #  end
  #
  #  _email!
  #end

  private

  def _sanity_check!
    if desired_gifts.empty?
      raise InternalConsistencyError, "You must have gifts to buy"
    elsif desired_gifts.any? { |x| not x.gift.is_a?(Gift) }
      raise InternalConsistencyError, "You specified a gift that wasn't a gift"
    elsif desired_gifts.any? { |x| x.quantity.to_i < 1 }
      raise InternalConsistencyError, "You specified a non-natural number for a gift quantity."
    elsif ENV['SHIPPO_TOKEN'].blank?
      raise InternalConsistencyError, "You must have a shippo token"
    elsif ENV['STRIPE_SECRET_KEY'].blank?
      raise InternalConsistencyError, "You must have a stripe token"
    elsif self.profile.owner != customer
      raise InternalConsistencyError, "The profile must belong to the customer"
    elsif !can_fulfill? && ENV['ALLOW_BOGUS_ORDER_CREATION']!='true'
      raise InternalConsistencyError, "There is at least one product that has insufficient quantities available."
    elsif gifts_span_vendors?
      raise InternalConsistencyError, "Each gift must only have products for one vendor"
    elsif self.cart_id.blank?
      raise InternalConsistencyError, "You must have a context for the purchase (cart ID)"
    end
  end

  def gifts_span_vendors?
    self.desired_gifts.any? do |dg|
      unique_vendors = dg.gift.products.map(&:vendor).uniq

      unique_vendors.length != 1
    end
  end

  def order_config
    return @order_config unless @order_config.nil?

    @order_config = {products: {}}

    # Aggregate order_config
    self.desired_gifts.each do |dg|
      dg.gift.products.each do |product|
        @order_config[:products][product] ||= {}
        @order_config[:products][product][:quantity] ||= 0
        @order_config[:products][product][:quantity] += dg.quantity
      end
    end

    @order_config
  end

  def can_fulfill?
    order_config[:products].none? do |product, values|
      Product.where(id: product.id).where('units_available < ?', values[:quantity]).any?
    end
  end

  def _description
  end

  def _do_stripe_auth!
    self.stripe_charge = Stripe::Charge.create(
      currency: USD,
      source: self.our_charge.token,
      capture: false, # <- Do an auth. This DOES NOT charge the card
      amount: self.our_charge.amount_in_cents,
      description: self.our_charge.description,
      idempotency_key: self.our_charge.idempotency_key,
      metadata: self.our_charge.metadata
    )
  end

  def _do_stripe_charge!
    self.stripe_charge = Stripe::Charge.retrieve(self.our_charge.charge_id)

    if self.stripe_charge.captured == false && (Time.now-self.our_charge.authed_at) > TIME_TO_CAPTURE
      raise InternalConsistencyError, "You didn't charge the auth soon enough. It must be done within 7 days"
    end

    self.stripe_charge.capture
  end

  def _verify_consistency!(captured:)
    unless self.stripe_charge.status.in? GOOD_STRIPE_STATUSES
      raise InternalConsistencyError, "unexpected status=#{self.stripe_charge.status.to_json}"
    end

    unless self.stripe_charge.captured == captured
      raise InternalConsistencyError, "Expected captured to be #{captured}. It wasn't"
    end

    unless self.stripe_charge.paid
      raise InternalConsistencyError, "unexpected paid=#{self.stripe_charge.paid.to_json}"
    end

    unless self.stripe_charge.outcome.type == 'authorized'
      raise InternalConsistencyError, "This should have been authorized"
    end

    unless self.stripe_charge.id
      raise InternalConsistencyError, "missing id"
    end

    if Rails.env.production? && !self.stripe_charge.livemode
      raise InternalConsistencyError, "unexpected livemode=#{self.stripe_charge.livemode.to_json}"
    end
  end

  #def _save_auth_results!
  #  self.our_charge.update_attributes({
  #    authed_at: Time.now,
  #    charge_id: self.stripe_charge.id,
  #    state: AUTH_SUCCEEDED
  #  })
  #end
  #
  #def _save_charge_results!
  #  self.our_charge.update_attributes({
  #    payment_made_at: Time.now,
  #    state: CHARGE_SUCCEEDED
  #  })
  #
  #  self.buyer_agreement.set_step!(BuyerAgreement::PAID)
  #end
  #
  #def _email!
  #  if self.charged?
  #    BuyerAgreementMailer.payment_success(self.our_charge.id).deliver_later
  #  end
  #end
  #
  #def _description
  #  "Reservation for #{self.vehicle.short_name}"
  #end

  def _safely
    yield
  rescue Stripe::CardError => e
    # Since it's a decline, Stripe::CardError will be caught
    body = e.json_body
    err  = body[:error]

    self.our_charge.update_attributes({
      http_status: e.http_status,
      error_type: err[:type],
      charge_id: err[:charge],
      error_code: err[:code],
      decline_code: err[:decline_code],
      error_param: err[:param],
      error_message: err[:message],
      state: DECLINED,
      declined_at: Time.now
    })

  rescue Stripe::RateLimitError => e
    self.our_charge.update_attributes({
      state: RATE_LIMIT_FAIL,
      error_message: e.message
    })
  rescue Stripe::InvalidRequestError => e
    self.our_charge.update_attributes({
      state: INVALID_REQUEST_FAIL,
      error_message: e.message
    })
  rescue Stripe::AuthenticationError => e
    self.our_charge.update_attributes({
      state: AUTHENTICATION_FAIL,
      error_message: e.message
    })
  rescue Stripe::APIConnectionError => e
    self.our_charge.update_attributes({
      state: API_CONNECTION_FAIL,
      error_message: e.message
    })
  rescue RechargeError => e
    raise
  rescue Exception => e
    raise
    self.our_charge.update_attributes({
      state: INTERNAL_CONSISTENCY_FAIL,
      error_message: (e.message + e.backtrace.to_s)
    })
  end

end
