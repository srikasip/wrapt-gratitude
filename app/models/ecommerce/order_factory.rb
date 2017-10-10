# Make a test order

module OrderFactory
  def self.create_order!
    raise "NEVER ON PRODUCTION" if Rails.env.production?

    # Fill in problems so we can make some something happen
    if Rails.env.development? || Rails.env.test?
      Product.where('weight_in_pounds is null or weight_in_pounds <= 0').update_all('weight_in_pounds=5')

      Vendor.where("street1 = 'unknown'").update_all(<<~SQL)
        street1 = '14325 Norwood',
        city = 'Leawood',
        state = 'KS',
        zip = '66212',
        country = 'US'
      SQL

      Product.where('units_available < 3').update_all('units_available = 10')

      Profile.where('name is null').update_all("name = 'Karen'")

      Gift.preload(:gift_parcels => :gift).find_each do |gift|
        if gift.pretty_parcel.blank?
          gift.gift_parcels.create(parcel: Parcel.active.where(usage: 'pretty').first)
        end
        if gift.shipping_parcel.blank?
          gift.gift_parcels.create(parcel: Parcel.active.where(usage: 'shipping').first)
        end
      end
    end

    stripe_token = Stripe::Token.create(
      :card => {
        :number => "4242424242424242",
        :exp_month => 8,
        :exp_year => 2018,
        :cvc => "314"
      },
    )

    profile = Profile.order('random()').first

    if ENV['USER'] == 'blackman'
      profile = User.find_by(email: 'tblackman@greenriver.com').owned_profiles.sample
    end

    customer = profile.owner

    gifts = Gift.order('random()').first(3)

    desired_gifts = gifts.map do |gift|
      # Can only buy one at a time right now given what I see in the mocks.
      CustomerPurchase::DesiredGift.new(gift, 1)
    end

    cart_id = SecureRandom.hex(10)

    customer_purchase = CustomerPurchase.new({
      cart_id: cart_id,
      customer: customer,
      profile: profile,
      desired_gifts: desired_gifts,
    })

    order = customer_purchase.generate_order!

    # A different page in the shopping process
    customer_purchase = CustomerPurchase.new(cart_id: cart_id)
    customer_purchase.gift_wrapt!(
      ActionController::Parameters.new({ customer_order: {
        gift_wrapt: ['1', '0'].sample,
        include_note: ['1', '0'].sample,
        note_from: "Your snookie",
        note_to: "Best friend ever",
        note_content: "Vivamus magna justo, lacinia eget consectetur sed, convallis at tellus. Pellentesque in ipsum id orci porta dapibus. Praesent sapien massa, convallis a pellentesque nec, egestas non nisi. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec velit neque, auctor sit amet aliquam vel, ullamcorper sit amet ligula. Curabitur arcu erat, accumsan id imperdiet et, porttitor at sem. Praesent sapien massa, convallis a pellentesque nec, egestas non nisi. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur non nulla sit amet nisl tempus convallis quis ac lectus. Vivamus suscipit tortor eget felis porttitor volutpat. Praesent sapien massa, convallis a pellentesque nec, egestas non nisi.  Sed porttitor lectus nibh. Praesent sapien massa, convallis a pellentesque nec, egestas non nisi. Curabitur arcu erat, accumsan id imperdiet et, porttitor at sem. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Nulla porttitor accumsan tincidunt. Cras ultricies ligula sed magna dictum porta. Vivamus suscipit tortor eget felis porttitor volutpat. Donec sollicitudin molestie malesuada. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec rutrum congue leo eget malesuada."
      }})
    )

    # A different page in the shopping process
    customer_purchase = CustomerPurchase.new(cart_id: cart_id)
    customer_purchase.set_address!(
      ActionController::Parameters.new({customer_order: {
        ship_street1: '319 Hague Rd',
        ship_street2: '',
        ship_city: 'Dummerston',
        ship_zip: '05301',
        ship_state: 'VT',
        ship_country: 'US',
        #phone:  '123-123-1234',
        email: 'example@example.com',
      }})
    )

    # usps only since I haven't yet developed the logic for handling shipping
    # across all the choices/vendors/pos to be consistent yet. usps options are always
    # choices, so they're safe.
    choices = customer_purchase.shipping_choices_for_view
    picked_choice = choices.sample

    # A difference virtual page load in the shopping process
    customer_purchase = CustomerPurchase.new(cart_id: cart_id)
    customer_purchase.pick_shipping!(picked_choice.value)

    # A difference virtual page load in the shopping process
    customer_purchase = CustomerPurchase.new(cart_id: cart_id)
    customer_purchase.init_our_charge_record!(stripe_token.id)

    # A difference virtual page load in the shopping process
    customer_purchase = CustomerPurchase.new(cart_id: cart_id)
    customer_purchase.authorize!

    # All the vendors acknowledge via emails and click-through to a page where they say it's okay.
    # This simulates that 99.5% of the time, a purchase order will be fulfillable.
    order.purchase_orders.each do |po|
      po.vendor_acknowledgement_status = Random.rand > 0.005 ? PurchaseOrder::FULFILL : PurchaseOrder::DO_NOT_FULFILL
      po.save!
    end

    # This happens when a vendor confirms they have inventory
    customer_purchase = CustomerPurchase.new(cart_id: cart_id)
    customer_purchase.update_from_vendor_responses!

    order
  end
end
