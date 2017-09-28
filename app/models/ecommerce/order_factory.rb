# Make a test order

module OrderFactory
  def self.create_order!
    if ENV['ALLOW_BOGUS_ORDER_CREATION']=='true'
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

      Gift.joins('left join gift_parcels ON (gifts.id = gift_parcels.gift_id)').where('gift_parcels.gift_id IS NULL').each do |gift|
        gift.gift_parcels.create(parcel: Parcel.active.where(usage: 'pretty').first)
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
    customer_purchase.gift_wrapt!({
      gift_wrapt: ['1', '0'].sample,
      include_note: ['1', '0'].sample,
      note_from: "Your snookie",
      note_to: "Best friend ever",
      note_content: "Vivamus magna justo, lacinia eget consectetur sed, convallis at tellus. Pellentesque in ipsum id orci porta dapibus. Praesent sapien massa, convallis a pellentesque nec, egestas non nisi. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec velit neque, auctor sit amet aliquam vel, ullamcorper sit amet ligula. Curabitur arcu erat, accumsan id imperdiet et, porttitor at sem. Praesent sapien massa, convallis a pellentesque nec, egestas non nisi. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur non nulla sit amet nisl tempus convallis quis ac lectus. Vivamus suscipit tortor eget felis porttitor volutpat. Praesent sapien massa, convallis a pellentesque nec, egestas non nisi.  Sed porttitor lectus nibh. Praesent sapien massa, convallis a pellentesque nec, egestas non nisi. Curabitur arcu erat, accumsan id imperdiet et, porttitor at sem. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Nulla porttitor accumsan tincidunt. Cras ultricies ligula sed magna dictum porta. Vivamus suscipit tortor eget felis porttitor volutpat. Donec sollicitudin molestie malesuada. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec rutrum congue leo eget malesuada."
    })

    # A different page in the shopping process
    customer_purchase = CustomerPurchase.new(cart_id: cart_id)
    customer_purchase.set_address_to!({
      street1: '319 Hague Rd',
      street2: '',
      city: 'Dummerston',
      zip: '05301',
      state: 'VT',
      country: 'US',
      phone:  '123-123-1234',
      email: 'example@example.com',
    })

    choices = customer_purchase.shipping_choices
    picked_choice = choices.keys.sample

    # A difference virtual page load in the shopping process
    customer_purchase = CustomerPurchase.new(cart_id: cart_id, stripe_token: stripe_token.id)
    customer_purchase.pick_shipping!(picked_choice)

    # A difference virtual page load in the shopping process
    customer_purchase = CustomerPurchase.new(cart_id: cart_id)
    customer_purchase.init_our_charge_record!
    #
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
    customer_purchase.charge_or_cancel_or_not_ready!

    order
  end
end
