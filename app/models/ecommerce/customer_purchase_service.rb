class CustomerPurchaseService
  include ChargeConstants

  DesiredGift = Struct.new(:gift, :quantity)

  SHIPPING_MARKUP = 1.05

  AbortOrderError = Class.new(StandardError)

  attr_accessor :cart_id, :customer, :desired_gifts, :customer_order,
    :our_charge, :profile, :shipment, :shipping_info, :shipping_label,
    :stripe_charge, :stripe_token, :purchase_orders

  def initialize(cart_id:, customer: nil, desired_gifts: nil, profile: nil, shipping_info: nil, stripe_token: nil)
    self.cart_id       = cart_id
    self.customer      = customer
    self.desired_gifts = desired_gifts
    self.profile       = profile
    self.shipping_info = shipping_info
    self.stripe_token  = stripe_token

    self.customer_order  = CustomerOrder.find_by(cart_id: self.cart_id)
    self.our_charge      = Charge.find_by(cart_id: self.cart_id)
    self.purchase_orders = self.customer_order.purchase_orders if self.customer_order.present?
  end

  def generate_order!
    _sanity_check!

    _safely do
      _init_order!
      _init_purchase_orders!
      _init_shipments!
    end

    self.customer_order
  end

  # Aggregate all the purchase orders together
  def shipping_choices
    return @shipping_choices unless @shipping_choices.nil?

    _check_shipping_choices_for_parallelism!

    @shipping_choices = {}

    self.customer_order.purchase_orders.each do |po|
      po.shipment.rates.each do |rate|
        token = rate.dig('servicelevel', 'token')
        name = rate.dig('servicelevel', 'name')

        @shipping_choices[token] ||= {}

        @shipping_choices[token]['name'] = name

        fields_to_copy = [
          'duration_terms',
          'estimated_days',
          'provider_image_200',
          'provider_image_75'
        ]

        fields_to_copy.each do |field|
          @shipping_choices[token][field] = rate[field]
        end

        @shipping_choices[token]['amount_in_dollars'] ||= 0.0
        @shipping_choices[token]['amount_in_dollars'] += rate['amount'].to_f
      end
    end

    @shipping_choices
  end

  def pick_shipping!(shippo_token)
    _sanity_check!

    if shipping_choices.keys.exclude?(shippo_token)
      raise InternalConsistencyError, "You picked an unknown or invalid shippo shipping token"
    end

    _safely do
      self.customer_order.update_attribute(:shippo_token_choice, shippo_token)
      _update_order_totals!(shippo_token)
      _init_our_charge_record!
    end
  end

  def authorize!
    _sanity_check!

    _safely do
      _do_stripe_auth!
      _verify_consistency!(captured: false)
      _save_auth_results!
    end

    self.our_charge
  end

  def charge!
    _sanity_check!

    _safely do
      _adjust_inventory!
      _do_stripe_charge!
      _verify_consistency!(captured: true)
      _save_charge_results!
      _purchase_shipping_labels!
    end
  end

  private

  def _sanity_check!
    if ENV['SHIPPO_TOKEN'].blank?
      raise InternalConsistencyError, "You must have a shippo token"
    elsif ENV['STRIPE_SECRET_KEY'].blank?
      raise InternalConsistencyError, "You must have a stripe token"
    elsif self.cart_id.blank?
      raise InternalConsistencyError, "You must have a context for the purchase (cart ID)"
    end

    # More to check for is we haven't gotten as far as initializing the order
    if self.customer_order.blank?
      if desired_gifts.blank?
        raise InternalConsistencyError, "You must have gifts to buy"
      elsif desired_gifts.any? { |x| not x.gift.is_a?(Gift) }
        raise InternalConsistencyError, "You specified a gift that wasn't a gift"
      elsif desired_gifts.any? { |x| x.quantity.to_i < 1 }
        raise InternalConsistencyError, "You specified a non-natural number for a gift quantity."
      elsif self.profile.owner != customer
        raise InternalConsistencyError, "The profile must belong to the customer"
      elsif !can_fulfill? && ENV['ALLOW_BOGUS_ORDER_CREATION']!='true'
        raise InternalConsistencyError, "There is at least one product that has insufficient quantities available."
      elsif gifts_span_vendors?
        raise InternalConsistencyError, "Each gift must only have products for one vendor"
      elsif desired_gifts.any? { |dg| dg.gift.weight_in_pounds.nil? || dg.gift.weight_in_pounds <= 0 }
        raise InternalConsistencyError, "You can't have weightless gifts."
      elsif self.shipping_info.present? && self.shipping_info.keys.to_set != [:name, :street1, :street2, :street3, :city, :zip, :state, :country, :phone, :email].to_set
        raise InternalConsistencyError, "Your shipping destination fields aren't precisely right."
      end
    end
  end

  def _init_order!
    self.customer_order = CustomerOrder.where(cart_id: self.cart_id).first_or_initialize

    self.customer_order.assign_attributes({
      user: self.customer,
      profile: self.profile,
      status: INITIALIZED,
      recipient_name: profile.name,
      ship_street1:   shipping_info[:street1],
      ship_street2:   shipping_info[:street2],
      ship_street3:   shipping_info[:street3],
      ship_city:      shipping_info[:city],
      ship_zip:       shipping_info[:zip],
      ship_state:     shipping_info[:state],
      ship_country:   shipping_info[:country]
    })

    self.customer_order.save!

    self.customer_order.line_items.destroy_all

    self.desired_gifts.each do |dg|
      gift = dg.gift

      self.customer_order.
        line_items.
        create!({
          orderable: gift,
          quantity: dg.quantity,
          vendor: gift.vendor,
          price_per_each_in_dollars: gift.price,
          total_price_in_dollars: gift.price * dg.quantity
        })
    end
  end

  def _init_purchase_orders!
    self.customer_order.purchase_orders.destroy_all

    self.desired_gifts.each do |dg|
      gift = dg.gift

      # One purchase order per individual gift.
      dg.quantity.times do
        purchase_order = PurchaseOrder.create!({
          customer_order: self.customer_order,
          vendor: gift.vendor,
          gift: gift,
          total_due_in_cents: gift.cost * 100
        })

        purchase_order.line_items.destroy_all

        gift.products.each do |product|
          purchase_order.line_items.create!({
            orderable: product,
            quantity: 1,
            vendor: gift.vendor,
            price_per_each_in_dollars: product.wrapt_cost,
            total_price_in_dollars: product.wrapt_cost
          })
        end
      end
    end

    self.customer_order.purchase_orders.reload
  end

  def _init_shipments!
    self.customer_order.purchase_orders.each do |purchase_order|
      self.shipment = Shipment.where(cart_id: self.cart_id, purchase_order: purchase_order).first_or_initialize

      self.shipment.address_from =
        purchase_order.
          vendor.
          attributes.
          keep_if { |key| key.in?(["name", "street1", "street2", "street3", "city", "state", "zip", "country", "phone", "email"]) }

      self.shipment.address_to = self.shipping_info

      parcel = purchase_order.shippo_parcel_hash

      if parcel.blank?
        if ENV['ALLOW_BOGUS_ORDER_CREATION']=='true'
          new_parcel = Parcel.dummy_parcel
          GiftParcel.create!({gift: purchase_order.gift, parcel: new_parcel})
          parcel = purchase_order.reload.shippo_parcel_hash
        else
          raise InternalConsistencyError, "need a box!"
        end
      end

      self.shipment.parcel = parcel

      self.shipment.api_response = nil

      self.shipment.run!

      self.shipment.save!
    end
  end

  def _check_shipping_choices_for_parallelism!
    uniq_tokens = self.customer_order.purchase_orders.map do |po|
      po.shipment.rates.map { |x| x.dig('servicelevel', 'token') }.sort
    end.uniq

    if uniq_tokens.length != 1
      raise InternalConsistencyError, "All POs should have same number and type of shipping choices"
    end
  end

  def _update_order_totals!(shippo_token)
    co = self.customer_order

    co.subtotal_in_cents        = 0
    co.taxes_in_cents           = 0
    co.shipping_in_cents        = 0
    co.shipping_cost_in_cents   = 0
    co.total_to_charge_in_cents = 0

    co.line_items.each do |line_item|
      co.subtotal_in_cents += line_item.total_price_in_dollars * 100
    end

    co.purchase_orders.each do |po|
      rate = po.shipment.rates.find { |x| x.dig('servicelevel', 'token') == shippo_token }

      co.shipping_cost_in_cents += rate['amount'].to_f * 100

      po.update_attributes({
        shipping_cost_in_cents: rate['amount'].to_f * 100,
        shipping_in_cents: rate['amount'].to_f * 100 * SHIPPING_MARKUP
      })
    end

    co.shipping_in_cents = co.shipping_cost_in_cents * SHIPPING_MARKUP

    # TODO: Taxes when we know
    co.taxes_in_cents = 0.0

    co.total_to_charge_in_cents = co.subtotal_in_cents + co.shipping_in_cents + co.taxes_in_cents

    co.save!
  end

  def _init_our_charge_record!
    if self.stripe_token.blank?
      raise InternalConsistencyError, "You must have a stripe token to even think of charging a card"
    end

    self.our_charge = Charge.where(cart_id: self.cart_id).first_or_initialize

    if self.our_charge.charged?
      raise InternalConsistencyError, "Initing a charge record, but it's already been charged."
    end

    self.our_charge.assign_attributes({
      token: self.stripe_token,
      customer_order: self.customer_order,
      status: INITIALIZED,
      amount_in_cents: self.customer_order.total_to_charge_in_cents,
      description: "Gifts for #{customer_order.profile_name}",
      idempotency_key: SecureRandom.hex(10),
      idempotency_key_expires_at: (Time.now+1.day),
      metadata: {
        user_id: customer_order.user_id,
        profile_id: customer_order.profile_id,
        gifts: self.customer_order.gifts.map(&:name).join('; '),
        customer_order_number: customer_order.order_number
      }
    })

    self.customer_order.update_attribute(:status, CustomerOrder::SUBMITTED)

    self.our_charge.save!
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

  def _do_stripe_auth!
    self.stripe_charge = Stripe::Charge.create({
        currency: USD,
        source: self.our_charge.token,
        capture: false, # <- Do an auth. This DOES NOT charge the card
        amount: self.our_charge.amount_in_cents,
        description: self.our_charge.description,
        metadata: self.our_charge.metadata
      },{
        idempotency_key: self.our_charge.idempotency_key
      }
    )
  end

  def _adjust_inventory!
    self.purchase_orders.flat_map(&:line_items).each do |line_item|
      product = line_item.orderable
      units_available = product.units_available
      if units_available > 0
        product.update_attribute(:units_available, units_available - 1)
      else
        # This is transactional, so the above decrements will be rolled back.
        raise AbortOrderError, "A product has become unavailable while customer was shopping"
      end
    end
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

  def _save_auth_results!
    self.our_charge.update_attributes({
      authed_at: Time.now,
      charge_id: self.stripe_charge.id,
      status: AUTH_SUCCEEDED
    })
  end

  def _save_charge_results!
    self.our_charge.update_attributes({
      payment_made_at: Time.now,
      status: CHARGE_SUCCEEDED
    })

    self.customer_order.update_attribute(:status, CustomerOrder::PROCESSING)
  end

  def _purchase_shipping_labels!
    choice = self.customer_order.shippo_token_choice

    self.customer_order.purchase_orders.each do |po|
      rate = po.shipment.rates.find { |r| r.dig('servicelevel', 'token') == choice }
      shipment = po.shipment

      if Rails.env.production? && rate['test']
        raise InternalConsistencyError, "You should have real shipping labels on production"
      end

      shipping_label = ShippingLabel.where({
        shipment: shipment,
        cart_id: self.cart_id,
        purchase_order: po,
        customer_order: self.customer_order
      }).first_or_initialize

      shipping_label.shippo_object_id = rate['object_id']

      shipping_label.run!

      shipping_label.save!
    end
  end

  def _safely
    CustomerOrder.transaction do
      yield
    end
  rescue Shippo::Exceptions::APIServerError => e
    self.shipment.api_response = e.response
    self.shipment.success = false
    self.shipment.save!
    self.customer_order.update_attribute(:status, CustomerOrder::FAILED)
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
      status: DECLINED,
      declined_at: Time.now
    })

    self.customer_order.update_attribute(:status, CustomerOrder::FAILED)
  rescue Stripe::RateLimitError => e
    self.our_charge.update_attributes({
      status: RATE_LIMIT_FAIL,
      error_message: e.message
    })
    self.customer_order.update_attribute(:status, CustomerOrder::FAILED)
  rescue Stripe::InvalidRequestError => e
    self.our_charge.update_attributes({
      status: INVALID_REQUEST_FAIL,
      error_message: e.message
    })
    self.customer_order.update_attribute(:status, CustomerOrder::FAILED)
  rescue Stripe::AuthenticationError => e
    self.our_charge.update_attributes({
      status: AUTHENTICATION_FAIL,
      error_message: e.message
    })
    self.customer_order.update_attribute(:status, CustomerOrder::FAILED)
  rescue Stripe::APIConnectionError => e
    self.our_charge.update_attributes({
      status: API_CONNECTION_FAIL,
      error_message: e.message
    })
    self.customer_order.update_attribute(:status, CustomerOrder::FAILED)
  rescue RechargeError => e
    raise
  rescue Exception => e
    if self.our_charge.present?
      self.our_charge.update_attributes({
        status: INTERNAL_CONSISTENCY_FAIL,
        error_message: (e.message + e.backtrace.to_s)
      })
    end
    if self.customer_order.present? && self.customer_order.persisted?
      self.customer_order.update_attribute(:status, CustomerOrder::FAILED)
    end
    raise
  end
end
