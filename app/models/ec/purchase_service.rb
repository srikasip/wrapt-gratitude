# This is a service object that orchestrates creating an order and associated
# vendor purchase orders along with shipping, taxes, credit card charging, and
# email messaging associated with these things.

module Ec
  class PurchaseService
    include ChargeConstants
    include OrderStatuses

    AbortOrderError = Class.new(StandardError)

    attr_accessor :cart_id, :customer, :desired_gifts, :customer_order,
      :profile, :shipping_label,
      :purchase_orders, :charging_service, :shipping_service, :tax_service

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
      self.customer       ||= self.customer_order&.user
      self.profile        ||= self.customer_order&.profile
      self.tax_service      = TaxService.new(cart_id: self.cart_id, customer_order: self.customer_order)
    end

    def self.find_existing_cart_or_initialize(profile:,user:)
      existing_order = user.customer_orders.for_profile(profile).initialized_only.newest

      cart_id = \
        if existing_order
          existing_order.cart_id
        else
          profile.id.to_s+SecureRandom.hex(16)
        end

      desired_gifts = profile.gift_selections.map do |gs|
        DesiredGift.new(gs.gift, 1)
      end

      PurchaseService.new({
        cart_id: cart_id,
        customer: user,
        desired_gifts: desired_gifts,
        profile: profile,
      })
    end

    def in_progress?
      self.customer_order.status == INITIALIZED
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

      whitelisted_params = params.require(:ec_customer_order).permit(:gift_wrapt, :include_note, :note_content, :note_envelope_text)

      _safely do
        self.customer_order.assign_attributes(whitelisted_params)
        @result = self.customer_order.save!
      end

      @result
    end

    def set_giftee_name!(params)
      whitelisted_params = params.require(:ec_customer_order).permit(profile: [:first_name, :last_name])['profile']

      unless self.profile.update_attributes(whitelisted_params)
        return false
      end

      if self.customer_order.shipping_to_giftee?
        self.customer_order.update_attribute(:recipient_name, profile.name)
      end
    end

    def set_address!(params)
      _sanity_check!

      required_fields = ['ship_street1', 'ship_city', 'ship_zip', 'ship_state' ].to_set

      permitted_fields = required_fields.to_a + ['ship_street2', 'ship_country', 'ship_to']

      whitelisted_params = nil
      new_address = nil

      if params['ec_customer_order']['ship_to'] == 'ship_to_giftee'
        self.customer_order.update_attributes({
          recipient_name: self.profile.name,
          shipping_to_giftee: true
        })
      else
        self.customer_order.update_attributes({
          recipient_name: self.customer.full_name,
          shipping_to_giftee: false
        })
      end

      if params['ec_customer_order']['address_id'] != 'new_address' && params['ec_customer_order']['ship_to'] == 'ship_to_customer'
        address = self.customer.addresses.find(params['ec_customer_order']['address_id'])
        whitelisted_params = {
          ship_to: params['ec_customer_order']['ship_to'],
          address_id: address.id,
          ship_street1: address.street1,
          ship_street2: address.street2,
          ship_city: address.city,
          ship_state: address.state,
          ship_zip: address.zip
        }
      else
        whitelisted_params = params.require(:ec_customer_order).permit(*permitted_fields)

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

        # Don't make a new one if there is already a matching address
        matching_address_scope = params['ec_customer_order']['ship_to'] == 'ship_to_giftee' ? self.profile.addresses : self.customer.addresses
        matching_address = matching_address_scope.
          where(params_to_save)
        if matching_address.any?
          new_address = matching_address.first
        else
          new_address = matching_address_scope.create(params_to_save)
        end

        if !new_address.valid?
          self.customer_order.errors[:base] += new_address.errors.full_messages
        end
      end

      _safely do
        self.customer_order.assign_attributes(whitelisted_params)
        if new_address.present?
          self.customer_order.address = new_address
        end
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
        update_order_totals!
      end
    end

    def init_our_charge_record!(params)
      _safely do
        update_order_totals!
      end
      self.charging_service.init_our_charge_record!(params)
    end

    def authorize!
      _sanity_check!

      charging_service.authorize!({
        after_hook: -> {
          self.customer_order.status = SUBMITTED
          self.customer_order.save!

          self.customer_order.purchase_orders.update_all(status: SUBMITTED)
          _email_vendors_the_acknowledgement_link!
          _email_customer_that_order_was_received!
          _remove_gifts_from_gift_basket!
        }
      })
    end

    delegate :card_authorized?, to: :charging_service

    delegate :expected_delivery, to: :shipping_service

    def update_from_vendor_responses!
      _sanity_check!

      purchase_orders.each do |po|
        if po.vendor_rejected? && !po.cancelled?
          CancelService.new(purchase_order: po).run!
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
      else
        Rails.logger.info "Already charged"
      end

      self.shipping_service.purchase_shipping_labels!
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
      purchase_orders.okay_to_fulfill.count == purchase_orders.count \
      &&
      purchase_orders.none?(&:cancelled?)
    end

    def all_vendors_cancelled?
      purchase_orders.all?(&:cancelled?)
    end

    delegate :need_shipping_calculated, to: :customer_order

    def update_order_totals!
      co = self.customer_order.reload
      shipping_choice = co.shipping_choice

      co.subtotal_in_cents        = 0
      co.handling_in_cents        = 0
      co.handling_cost_in_cents   = 0
      co.shipping_in_cents        = 0
      co.shipping_cost_in_cents   = 0
      co.total_to_charge_in_cents = 0
      co.promo_total_in_cents     = 0
      co.promo_free_subtotal_in_cents = 0

      _calculate_promo_discount!

      co.purchase_orders.each do |po|
        vendor = po.vendor
        rate = ShippingService.find_rate(rates: po.shipment.rates, shipping_choice: shipping_choice, vendor: vendor)
        s_and_h = ShippingService.get_shipping_and_handling_for_one_purchase_order(rate: rate, vendor: vendor)

        co.need_shipping_calculated = false

        co.shipping_cost_in_cents += s_and_h.shipping_cost_in_cents
        co.handling_cost_in_cents += s_and_h.handling_cost_in_cents
        co.handling_in_cents      += s_and_h.handling_in_cents
        co.shipping_in_cents      += s_and_h.shipping_in_cents

        po.update_attributes({
          shipping_cost_in_cents: s_and_h.shipping_cost_in_cents,
          shipping_in_cents: s_and_h.shipping_in_cents,
          handling_cost_in_cents: s_and_h.handling_cost_in_cents,
          handling_in_cents: s_and_h.handling_in_cents,
        })
      end

      # Must come after shipping and promo code taken care of as those affect taxable amount
      self.tax_service.estimate!
      co.taxes_in_cents = self.tax_service.tax_in_cents

      co.purchase_orders.each do |po|
        # If we have to refund, we need to know this at the PO level.
        gift_line_items = po.line_items.flat_map(&:related_line_items).uniq
        raise "Should only be one gift" if gift_line_items.length != 1
        gift_amount_for_customer_in_cents = (gift_line_items.first.taxable_total_price_in_dollars * 100.0).round

        co.subtotal_in_cents += gift_amount_for_customer_in_cents

        co.promo_free_subtotal_in_cents += (gift_line_items.first.total_price_in_dollars * 100.0).round

        po.update_attributes({
          tax_amount_for_customer_in_cents: self.tax_service.tax_in_cents_for_purchase_order(po),
          gift_amount_for_customer_in_cents: gift_amount_for_customer_in_cents
        })
      end

      co.total_to_charge_in_cents = \
        co.subtotal_in_cents +
        co.shipping_in_cents +
        co.handling_in_cents +
        co.taxes_in_cents

      co.save!
    end

    delegate :force_shipping!, :rate_for_gift, to: :shipping_service

    private

    def promo_code
      PromoCode.new(mode: customer_order.promo_code_mode, amount: customer_order.promo_code_amount)
    end

    def _calculate_promo_discount!
      discount_cents_remaining =
        if promo_code.fixed?
          promo_code.delta_in_cents()
        else
          0
        end

      customer_order.line_items.each do |line_item|
        amount_in_cents = line_item.total_price_in_dollars * 100

        delta_in_cents = \
          if promo_code.percent?
            promo_code.delta_in_cents(amount_in_cents)
          elsif promo_code.fixed? && amount_in_cents >= discount_cents_remaining
            saveit = discount_cents_remaining
            discount_cents_remaining -= discount_cents_remaining
            saveit
          elsif promo_code.fixed? && amount_in_cents < discount_cents_remaining
            discount_cents_remaining -= amount_in_cents
            amount_in_cents
          else
            0
          end

        customer_order.promo_total_in_cents += delta_in_cents

        line_item.taxable_total_price_in_dollars = (line_item.total_price_in_dollars - (delta_in_cents / 100.0)).round(2)

        line_item.save!
      end
    end

    def _unconditional_charge!
      Rails.logger.info "Charging cart ID #{cart_id}. Also adjusting inventory."
      charging_service.charge!({
        before_hook: -> { _adjust_inventory! },
        after_hook: -> {
          self.tax_service.capture!
          self.tax_service.reconcile!
          Ec::PurchaseService::CancelService.recancel_if_needed!(customer_order)
        }
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

      order_number = InternalOrderNumber.next_customer_order_number

      self.customer_order.assign_attributes({
        order_number: order_number,
        user: self.customer,
        profile: self.profile,
        status: ORDER_INITIALIZED,
        shipping_to_giftee: true,
        recipient_name: profile.name,
        ship_street1: '',
        ship_city:    '',
        ship_zip:     '',
        ship_state:   '',
        ship_country: 'US',
        need_shipping_calculated: true
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

      po_index = -1

      self.desired_gifts.each do |dg|
        gift = dg.gift

        # One purchase order per individual gift.
        dg.quantity.times do
          po_index += 1
          purchase_order_number = InternalOrderNumber.make_purchase_order_number(self.customer_order.order_number, po_index)

          purchase_order = PurchaseOrder.create!({
            order_number: purchase_order_number,
            customer_order: self.customer_order,
            vendor: gift.vendor,
            gift: gift,
            status: ORDER_INITIALIZED,
            total_due_in_cents: gift.cost * 100
          })

          purchase_order.line_items.destroy_all

          co_line_item = self.customer_order.line_items.find_by(orderable: gift)

          gift.products.each do |product|
            po_line_item = purchase_order.line_items.create!({
              orderable: product,
              quantity: 1,
              vendor: gift.vendor,
              price_per_each_in_dollars: product.wrapt_cost,
              total_price_in_dollars: product.wrapt_cost,
            })

            RelatedLineItem.create!({
              purchase_order: purchase_order,
              customer_order: customer_order,
              purchase_order_line_item: po_line_item,
              customer_order_line_item: co_line_item
            })
          end
        end
      end

      self.customer_order.purchase_orders.reload
    end

    def _email_vendors_the_acknowledgement_link!
      purchase_orders.each do |po|
        VendorMailer.acknowledge_order_request(po.id).deliver_later
      end
    end

    def _email_customer_that_order_was_received!
      ::CustomerOrderMailer.order_received(customer_order.id).deliver_later
    end

    def gifts_span_vendors?
      self.desired_gifts.any? do |dg|
        unique_vendors = dg.gift.products.map(&:vendor).uniq

        unique_vendors.length != 1
      end
    end

    def can_fulfill?
      self.desired_gifts.all? do |dg|
        dg.gift.units_available >= dg.quantity
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
    rescue Exception => e
      Rails.logger.fatal { "[PURCHASE_SERVICE] #{e.message}" }
      if self.customer_order.present? && self.customer_order.persisted?
        self.customer_order.update_attribute(:status, CustomerOrder::FAILED)
      end
      raise
    end
  end
end
