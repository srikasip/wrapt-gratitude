class CustomerPurchase::ShippingService
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
        phone:   co.user.email,
        email:   co.user.email
      }

      parcel = purchase_order.shippo_parcel_hash

      if parcel.blank?
        @shipments_okay = false

        # It's exceptional for a gift not to have a box.
        raise InternalConsistencyError, "need a box!"
      end

      shipment.parcel = parcel
      shipment.api_response = nil
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

    # Each PO can have a different set of shipping options. Need to handle PT story #151525308
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

  def shipping_choices_for_view
    shipping_choices.map do |choice, data|
      [choice.gsub('_', ' ').titleize, choice]
    end
  end

  def things_look_shipable?
    shipping_choices

    @shipments_okay
  end

  def pick_shipping!(shippo_token, after_hook: -> {} )
    _sanity_check!

    if shipping_choices.keys.exclude?(shippo_token)
      raise InternalConsistencyError, "You picked an unknown or invalid shippo shipping token"
    end

    _safely do
      self.customer_order.update_attribute(:shippo_token_choice, shippo_token)
      after_hook.call
    end
  end

  def purchase_shipping_labels!
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

    raise "WIP"
    _update_the_customer_order_and_or_purchase_order_statuses!
  end

  private

  def _check_shipping_choices_for_parallelism!
    uniq_tokens = self.customer_order.purchase_orders.map do |po|
      po.shipment.rates.map { |x| x.dig('servicelevel', 'token') }.sort
    end.uniq

    if uniq_tokens.length != 1
      raise InternalConsistencyError, "All POs should have same number and type of shipping choices"
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

    raise "also check shippo token isn't test when in production"
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
