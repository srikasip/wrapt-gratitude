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
      CustomerPurchaseService::DesiredGift.new(gift, Random.rand(3)+1)
    end

    cart_id = SecureRandom.hex(10)

    customer_purchase = CustomerPurchaseService.new({
      cart_id: cart_id,
      customer: customer,
      profile: profile,
      desired_gifts: desired_gifts,
      shipping_info: {
        name: 'Mr. Some Receiver',
        street1: '319 Hague Rd',
        street2: '',
        street3: '',
        city: 'Dummerston',
        zip: '05301',
        state: 'VT',
        country: 'US',
        phone:  '123-123-1234',
        email: 'example@example.com',
      }
    })

    order = customer_purchase.generate_order!

    choices = customer_purchase.shipping_choices

    picked_choice = choices.keys.sample

    # A difference virtual page load in the shopping process
    customer_purchase = CustomerPurchaseService.new(cart_id: cart_id, stripe_token: stripe_token.id)
    customer_purchase.pick_shipping!(picked_choice)

    # A difference virtual page load in the shopping process
    customer_purchase = CustomerPurchaseService.new(cart_id: cart_id)
    customer_purchase.authorize!

    # A difference virtual page load in the shopping process
    customer_purchase = CustomerPurchaseService.new(cart_id: cart_id)
    customer_purchase.charge!

    order
  end
end
