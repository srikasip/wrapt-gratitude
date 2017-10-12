# This is a service object that orchestrates creating an order and associated
# vendor purchase orders along with shipping, taxes, credit card charging, and
# email messaging associated with these things.

class PurchaseService
  include ChargeConstants
  include OrderStatuses

  AbortOrderError = Class.new(StandardError)

  attr_accessor :cart_id, :customer, :desired_gifts, :customer_order,
    :profile, :shipping_label,
    :purchase_orders, :charging_service, :shipping_service

  delegate :our_charge, to: :charging_service, prefix: false

  def initialize(cart_id:, customer: nil, desired_gifts: nil, profile: nil)
    self.cart_id       = cart_id
    self.customer      = customer
    self.desired_gifts = desired_gifts
    self.profile       = profile

    self.customer_order   = CustomerOrder.find_by(cart_id: self.cart_id)
    self.purchase_orders  = self.customer_order.purchase_orders if self.customer_order.present?
    self.charging_service = ChargingService.new(cart_id: cart_id)
    self.shipping_service = ShippingService.new(cart_id: cart_id, customer_order: customer_order)
    self.customer       ||= self.customer_order.user
    self.profile        ||= self.customer_order.profile
  end

  def generate_order!
    _sanity_check!

    _safely do
      _init_order!
      _init_purchase_orders!
    end

    self.customer_order
  end

  def gift_wrapt!(params)
    _sanity_check!

    whitelisted_params = params.require(:customer_order).permit(:gift_wrapt, :include_note, :note_from, :note_to, :note_content)

    _safely do
      self.customer_order.assign_attributes(whitelisted_params)
      @result = self.customer_order.save!
    end

    @result
  end

  def set_address!(params)
    _sanity_check!

    required_fields = ['ship_street1', 'ship_city', 'ship_zip', 'ship_state' ].to_set

    permitted_fields = required_fields.to_a + ['ship_street2', 'ship_country']

    whitelisted_params = nil

    if params['saved_address'] != 'new_address' && params[:customer_order][:ship_street1].blank?
      address = Address.find(params['saved_address'])
      whitelisted_params = {
        ship_street1: address.street1,
        ship_street2: address.street2,
        ship_city: address.city,
        ship_state: address.state,
        ship_zip: address.zip
      }
    else
      whitelisted_params = params.require(:customer_order).permit(*permitted_fields)

      if whitelisted_params.blank? || whitelisted_params.keys.to_set.intersection(required_fields) != required_fields
        raise InternalConsistencyError, "Your shipping destination fields aren't complete enough."
      end

      params_to_save = {
        street1: whitelisted_params[:ship_street1],
        street2: whitelisted_params[:ship_street2],
        city: whitelisted_params[:ship_city],
        state: whitelisted_params[:ship_state],
        zip: whitelisted_params[:ship_zip]
      }

      if params['toggle_address_choice'] == 'ship_to_giftee'
        self.profile.addresses.create(params_to_save)
      else
        self.customer.addresses.create(params_to_save)
      end
    end

    _safely do
      self.customer_order.assign_attributes(whitelisted_params)
      if self.customer_order.save
        self.shipping_service.init_shipments!
      end
    end
  end

  delegate :shipping_choices, :shipping_choices_for_view, :things_look_shipable?,
    to: :shipping_service

  def pick_shipping!(shippo_token)
    _sanity_check!

    self.shipping_service.pick_shipping!(shippo_token)

    _safely do
      _update_order_totals!
    end
  end

  delegate :init_our_charge_record!, to: :charging_service

  def authorize!
    _sanity_check!
    charging_service.authorize!({
      after_hook: -> {
        self.customer_order.status = SUBMITTED
        self.customer_order.save!

        self.customer_order.purchase_orders.update_all(status: SUBMITTED)
        _email_vendors_the_acknowledgement_link!
        _email_customer_that_order_was_received!
      }
    })
  end

  delegate :expected_delivery, to: :shipping_service

  def update_from_vendor_responses!
    _sanity_check!

    purchase_orders.each do |po|
      if po.vendor_rejected?
        raise 'maybe catch purchase orders *transitioning* to cancelled and email on that hook'
        po.update_attribute(:status, CANCELLED)
        customer_order.update_attribute(:status, PARTIALLY_CANCELLED)
      elsif po.vendor_accepted?
        po.update_attribute(:status, PROCESSING)
      else
        :havent_responded_yet
      end
    end

    if all_vendors_accepted?
      customer_order.update_attribute(:status, PROCESSING)
    end

    if okay_to_charge?
      _unconditional_charge!
      _remove_gifts_from_gift_basket!
    elsif should_cancel?
      cancel_order!
    else
      Rails.logger.info(<<~EOS)
        Already charged or cannot cannot yet cancel for sure.  There are only
        un-acknowledged vendor purchase orders left.
      EOS
    end

    self.shipping_service.purchase_shipping_labels!
  end

  def cancel_order!
    Rails.logger.info "Canceling some or all of cart ID #{cart_id}. One or more vendors cannot fulfill."
    raise "WIP"
    _figure_which_pos_to_cancel
    _calculate_amount_to_refund
    self.charging_service.refund(x)
    _update_status_of_customer_order
    _email_customer_about_cancel
    _email_vendors_about_cancel
  end

  def okay_to_charge?
    # The first vendor to accept, triggers a charge. In any other had or will
    # reject, we'll generate a refund.
    purchase_orders.any?(&:vendor_accepted?) && charging_service.authed?
  end

  def should_cancel?
    any_rejections = purchase_orders.do_not_fulfill.any?

    all_vendors_responded? && any_rejections
  end

  def all_vendors_responded?
    purchase_orders.acknowledged.count == purchase_orders.count
  end

  def all_vendors_accepted?
    purchase_orders.okay_to_fulfill.count == purchase_orders.count
  end

  private

  def _unconditional_charge!
    Rails.logger.info "Charging cart ID #{cart_id}. Also adjusting inventory."
    charging_service.charge!({
      before_hook: -> { _adjust_inventory! }
    })
  end

  def _remove_gifts_from_gift_basket!
    self.customer_order.profile.gift_selections.destroy_all
  end

  def _sanity_check!
    if self.cart_id.blank?
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
      end
    end
  end

  def _init_order!
    self.customer_order = CustomerOrder.where(cart_id: self.cart_id).first_or_initialize

    self.customer_order.assign_attributes({
      user: self.customer,
      profile: self.profile,
      status: ORDER_INITIALIZED,
      recipient_name: profile.name,
      ship_street1: '',
      ship_city:    '',
      ship_zip:     '',
      ship_state:   '',
      ship_country: 'US',
      note_from: self.customer.full_name,
      note_to: profile.name
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
          price_per_each_in_dollars: gift.selling_price,
          total_price_in_dollars: gift.selling_price * dg.quantity
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
          status: ORDER_INITIALIZED,
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

  def _update_order_totals!
    co = self.customer_order
    shipping_choice = co.shipping_choice

    co.subtotal_in_cents        = 0
    co.taxes_in_cents           = TaxService.new(cart_id: self.cart_id).estimated_tax_in_cents
    co.handling_in_cents        = 0
    co.handling_cost_in_cents   = 0
    co.shipping_in_cents        = 0
    co.shipping_cost_in_cents   = 0
    co.total_to_charge_in_cents = 0

    co.line_items.each do |line_item|
      co.subtotal_in_cents += line_item.total_price_in_dollars * 100
    end

    co.purchase_orders.each do |po|
      vendor = po.vendor
      rate = ShippingService.find_rate(rates: po.shipment.rates, shipping_choice: shipping_choice, vendor: vendor)
      s_and_h = ShippingService.get_shipping_and_handling_for_one_purchase_order(rate: rate, vendor: vendor)

      co.shipping_cost_in_cents += s_and_h.shipping_cost_in_cents
      co.handling_cost_in_cents += s_and_h.handling_cost_in_cents
      co.handling_in_cents      += s_and_h.handling_in_cents
      co.shipping_in_cents      += s_and_h.shipping_in_cents

      po.update_attributes({
        shipping_cost_in_cents: s_and_h.shipping_cost_in_cents,
        shipping_in_cents: s_and_h.shipping_in_cents,
        handling_cost_in_cents: s_and_h.handling_cost_in_cents,
        handling_in_cents: s_and_h.handling_in_cents
      })
    end

    co.total_to_charge_in_cents = co.subtotal_in_cents + co.shipping_in_cents + co.handling_in_cents + co.taxes_in_cents

    co.save!
  end

  def _email_vendors_the_acknowledgement_link!
    purchase_orders.each do |po|
      VendorMailer.acknowledge_order_request(po.id).deliver_later
    end
  end

  def _email_customer_that_order_was_received!
    CustomerOrderMailer.order_received(customer_order.id).deliver_later
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

  def _safely
    CustomerOrder.transaction do
      yield
    end
  rescue Exception
    if self.customer_order.present? && self.customer_order.persisted?
      self.customer_order.update_attribute(:status, CustomerOrder::FAILED)
    end
    raise
  end
end
