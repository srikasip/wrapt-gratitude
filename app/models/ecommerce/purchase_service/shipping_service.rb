class PurchaseService::ShippingService
  include ActionView::Helpers::NumberHelper
  include OrderStatuses

  SHIPPING_MARKUP = 1.02
  DAYS_FOR_VENDORS_TO_APPROVE = 1
  SHIPPING_FUDGE_DAYS = 2

  attr_accessor :cart_id, :customer_order

  def initialize(cart_id:, customer_order:nil)
    self.cart_id        = cart_id
    self.customer_order = customer_order || CustomerOrder.find_by(cart_id: self.cart_id)
  end

  def init_shipments!
    @shipments_okay = true

    if customer_order.ship_street1.blank? ||
      customer_order.ship_city.blank? ||
      customer_order.ship_state.blank? ||
      customer_order.ship_zip.blank? ||
      customer_order.ship_country.blank?

      @shipments_okay = false
      return
    end

    self.customer_order.purchase_orders.each do |purchase_order|
      shipment = Shipment.where(cart_id: self.cart_id, purchase_order: purchase_order).first_or_initialize

      shipment.address_from =
        purchase_order.
          vendor.
          attributes.
          keep_if { |key| key.in?(["name", "street1", "street2", "street3", "city", "state", "zip", "country", "phone", "email"]) }

      co = self.customer_order
      shipment.address_to = {
        name: co.profile.name,
        street1: co.ship_street1,
        street2: co.ship_street2,
        street3: co.ship_street3,
        city:    co.ship_city,
        state:   co.ship_state,
        zip:     co.ship_zip,
        country: co.ship_country,
        #phone:   co.user.phone,
        email:   co.user.email
      }

      parcel = purchase_order.shippo_parcel_hash

      if parcel.blank?
        @shipments_okay = false

        # It's exceptional for a gift not to have a box.
        raise InternalConsistencyError, "need a box!"
      end

      if purchase_order.gift.insurance_in_dollars.to_i > 0
        shipment.insurance_in_dollars = gift.insurance_in_dollars
        shipment.description_of_what_to_insure = gift.name
      end

      shipment.parcel = parcel
      shipment.api_response = nil
      shipment.customer_order = customer_order
      shipment.run!
      shipment.save!

      if !shipment.success?
        @shipments_okay &= false
      end
    end
  end

  # Aggregate all the purchase orders together
  def shipping_choices
    return @shipping_choices unless @shipping_choices.nil?

    @shipping_choices = {
      fastest: OpenStruct.new({
          label: 'Fastest',
          value: 'fastest',
          estimated_days: 1,
          amount_in_dollars: 0.0
        }),
      cheapest: OpenStruct.new({
          label: 'Least Expensive',
          value: 'cheapest',
          estimated_days: 1,
          amount_in_dollars: 0.0
        })
    }

    self.customer_order.purchase_orders.each do |po|
      rates = po.shipment.rates
      vendor = po.vendor

      @shipping_choices.each_key do |shipping_choice|
        rate = PurchaseService::ShippingService.find_rate(rates: rates, shipping_choice: shipping_choice, vendor: vendor)
        s_and_h = PurchaseService::ShippingService.get_shipping_and_handling_for_one_purchase_order(rate: rate, vendor: vendor)

        @shipping_choices[shipping_choice]

        if rate['estimated_days'] > @shipping_choices[shipping_choice].estimated_days
          @shipping_choices[shipping_choice].estimated_days = rate['estimated_days']
        end

        @shipping_choices[shipping_choice].amount_in_dollars += s_and_h.combined_handling_in_dollars
      end
    end

    @shipping_choices.each_key do |shipping_choice|
      @shipping_choices[shipping_choice].annotated_label = "#{@shipping_choices[shipping_choice].label}: #{number_to_currency(@shipping_choices[shipping_choice].amount_in_dollars)}
      </br><small>in approximately #{@shipping_choices[shipping_choice].estimated_days} days</small>"
    end

    @shipping_choices
  end

  def things_look_shipable?
    @shipments_okay &&
      shipping_choices.values.map(&:amount_in_dollars).all? { |x| x > 1 }
  end

  def shipping_choices_for_view
    # TODO: if both choices are same price, don't give a choice
    shipping_choices.values
  end

  def pick_shipping!(shipping_choice, after_hook: -> {} )
    _sanity_check!

    if shipping_choices_for_view.none? { |x| x.value == shipping_choice }
      raise InternalConsistencyError, "You picked an unknown or invalid shipping choice"
    end

    _safely do
      self.customer_order.update_attribute(:shipping_choice, shipping_choice)
      after_hook.call
    end
  end

  def self.find_rate(rates:, shipping_choice:, vendor:)
    allowed_rates = rates.select do |rate|
      if vendor.shipping_service_levels.blank?
        # No choices mean all choices are okay
        true
      else
        # Limit choices to those allowed for this vendor
        vendor.shipping_service_levels.map(&:shippo_token).include?(rate.dig('servicelevel', 'name'))
      end
    end

    picked_rate = allowed_rates.find { |r| r['attributes'].include?(shipping_choice.upcase) }

    if picked_rate.nil?
      case shipping_choice.upcase
      when 'FASTEST'
        picked_rate = allowed_rates.sort_by { |r| r['estimated_days'].to_i }.first
      else
        picked_rate = allowed_rates.sort_by { |r| r['amount'].to_f }.first
      end
    end

    if picked_rate.nil?
      raise InternalConsistencyError, "Unable to find a way to ship!"
    end

    picked_rate
  end

  def self.get_shipping_and_handling_for_one_purchase_order(rate:, vendor:)
    OpenStruct.new.tap do |result|
      result.shipping_cost_in_cents = rate['amount'].to_f * 100
      result.shipping_in_cents = (result.shipping_cost_in_cents * SHIPPING_MARKUP).round
      result.handling_cost_in_cents = vendor.purchase_order_markup_in_cents
      result.handling_in_cents = result.handling_cost_in_cents
      result.combined_handling_in_cents = result.handling_in_cents + result.shipping_in_cents
      result.combined_handling_in_dollars = (result.combined_handling_in_cents / 100.0).round(2)
    end
  end

  # This is used before we've purchased the labels
  def expected_delivery
    estimated_days_min = 10
    estimated_days_max = 1

    _each_po_with_rate do |_, rate|
      if rate['estimated_days'] > estimated_days_max
        estimated_days_max = rate['estimated_days']
      end

      if rate['estimated_days'] < estimated_days_min
        estimated_days_min = rate['estimated_days']
      end
    end

    estimated_days_min += DAYS_FOR_VENDORS_TO_APPROVE
    estimated_days_max += DAYS_FOR_VENDORS_TO_APPROVE + SHIPPING_FUDGE_DAYS

    range = [customer_order.submitted_on + estimated_days_min, Date.today + estimated_days_max]

    fmt = ->(d) { d.strftime('%b %d, %Y') }

    text = \
      if range[0].month == range[1].month
        "#{range[0].strftime('%b')} #{range[0].day}-#{range[1].day}, #{range[0].year}"
      elsif range[0].year != range[1].year
        "#{fmt.(range[0])} to #{fmt.(range[1])}"
      else
        "#{range[0].strftime('%b')} #{range[0].day}-#{range[1].strftime('%b')} #{range[1].day}, #{range[0].year}"
      end

    OpenStruct.new(text: text, range: range)
  end

  def purchase_shipping_labels!
    _each_po_with_rate do |po, rate|
      # Don't even try if the vendor hasn't acknowledged with the affirmative.
      next if !po.fulfill?

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

      # Don't redo a successfully created label
      if shipping_label.persisted? && shipping_label.success?
        next
      end

      shipping_label.shippo_object_id = rate['object_id']
      shipping_label.carrier = rate['provider']
      shipping_label.service_level = rate.dig('servicelevel', 'name')

      shipping_label.run!

      shipping_label.save!
    end
  end

  def self.update_shipping_status!(shippo_data)
    shipping_label = ShippingLabel.find_by(shippo_object_id: data.dig('tracking_status', 'object_id'))

    shipping_label.update_attributes({
      eta: data['eta'],
      tracking_status: data.dig('tracking_status', 'status'),
      tracking_updated_at: data.dig('tracking_status', 'status_date'),
      tracking_payload: data
    })

    if shipping_label.shipped?
      purchase_order = shipping_label.purchase_order
      purchase_order.status = SHIPPED
      purchase_order.save!

      gift = purchase_order.gift
      gift.gifts_sent += purchase_order.quantity
      gift.save!

      if customer_order.purchase_orders.all?(&:shipped?)
        customer_order.status = SHIPPED
        customer_order.save!
      end

      CustomerOrderMailer.order_shipped(purchase_order.id).deliver_later
    end
  end

  private

  def _each_po_with_rate
    shipping_choice = self.customer_order.shipping_choice

    self.customer_order.purchase_orders.each do |po|
      rate = PurchaseService::ShippingService.find_rate(rates: po.shipment.rates, shipping_choice: shipping_choice, vendor: po.vendor)
      yield po, rate
    end
  end

  def _sanity_check!
    if ENV['SHIPPO_TOKEN'].blank?
      raise InternalConsistencyError, "You must have a shippo token"
    elsif ENV['SHIPPO_TOKEN'].match(/live/) && !Rails.env.production?
      raise InternalConsistencyError, <<~EOS
        Comment out these lines if you really want to use the production shippo
        key outside of production
      EOS
    elsif ENV['SHIPPO_TOKEN'].match(/test/) && Rails.env.production?
      raise InternalConsistencyError, <<~EOS
        Comment out these lines if you really want to use test mode for shippo
        on production
      EOS
    elsif self.cart_id.blank?
      raise InternalConsistencyError, "You must have a context for the purchase (cart ID)"
    end
  end

  def _safely
    Shipment.transaction do
      yield
    end
  rescue Shippo::Exceptions::APIServerError
    self.customer_order.update_attribute(:status, CustomerOrder::FAILED)
    raise
  end
end
