class CustomerPurchaseService
  include ChargeConstants

  DesiredGift = Struct.new(:gift, :quantity)

  SHIPPING_MARKUP = 1.05

  AbortOrderError = Class.new(StandardError)

  attr_accessor :cart_id, :customer, :desired_gifts, :customer_order,
    :profile, :shipment, :shipping_info, :shipping_label,
    :stripe_token, :purchase_orders, :charging_service

  def initialize(cart_id:, customer: nil, desired_gifts: nil, profile: nil, shipping_info: nil, stripe_token: nil)
    self.cart_id       = cart_id
    self.customer      = customer
    self.desired_gifts = desired_gifts
    self.profile       = profile
    self.shipping_info = shipping_info
    self.stripe_token  = stripe_token

    self.customer_order  = CustomerOrder.find_by(cart_id: self.cart_id)
    self.purchase_orders = self.customer_order.purchase_orders if self.customer_order.present?

    self.charging_service = ChargingService.new(cart_id: cart_id, stripe_token: stripe_token)
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
      charging_service.init_our_charge_record!
    end
  end

  def authorize!
    _sanity_check!
    charging_service.authorize!({
      after_hook: -> { _email_vendors_the_acknowledgement_link }
    })
  end

  def okay_to_charge?
    purchase_orders.all?(&:vendor_accepted?) && charge_service.authed?
  end

  def should_cancel?
    purchase_orders.any?(&:vendor_rejected?)
  end

  # Just because a vendor just acknowledged doesn't mean the order is ready
  # since all vendors need to acknowledge. One "cannot fulfill" cancels the whole
  # order
  def charge_or_cancel_or_not_ready!
    _sanity_check!
    if okay_to_charge?
      _unconditional_charge!
    elsif should_cancel?
      cancel_order!
    else
      Rails.logger.info "CANNOT Charge cart ID #{cart_id}. There remains un-acknowledged vendor purchase orders"
      :dont_know_yet
    end
  end

  def cancel_order!
    Rails.logger.info "canceling cart ID #{cart_id}. One or more vendors cannot fulfill"
    raise "WIP"
    email_customer_about_cancel
    email_vendors_about_cancel
  end

  private

  def _unconditional_charge!
    Rails.logger.info "Charging cart ID #{cart_id}. Also adjusting inventory and buying shipping labels"
    charging_service.charge!({
      before_hook: -> { _adjust_inventory! },
      after_hook: -> {
        _purchase_shipping_labels!
        _email_customer_now_maybe
        _email_vendors_with_everything_they_need_to_send_like_label_etc
      }
    })
  end

  def _sanity_check!
    if ENV['SHIPPO_TOKEN'].blank?
      raise InternalConsistencyError, "You must have a shippo token"
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
      elsif !can_fulfill?
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
        raise InternalConsistencyError, "need a box!"
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

  def gifts_span_vendors?
    self.desired_gifts.any? do |dg|
      unique_vendors = dg.gift.products.map(&:vendor).uniq

      unique_vendors.length != 1
    end
  end

  def can_fulfill?
    self.desired_gifts.all? do |dg|
      dg.gift.units_available > dg.quantity
    end
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
    self.shipment.save # Might not succeed. Such is life.
    self.customer_order.update_attribute(:status, CustomerOrder::FAILED)
  rescue Exception => e
    if self.customer_order.present? && self.customer_order.persisted?
      self.customer_order.update_attribute(:status, CustomerOrder::FAILED)
    end
    raise
  end
end
