# Make a test order

module OrderFactory
  def self.create_order!
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

    customer_purchase = CustomerPurchaseService.new({
      cart_id: SecureRandom.hex(10),
      stripe_token: stripe_token.id,
      customer: customer,
      profile: profile,
      desired_gifts: desired_gifts,
      shipping_info: {
        ship_address_1: '319 Hague Rd',
        ship_city: 'Dummerston',
        ship_postal_code: '05301',
        ship_region: 'VT',
        ship_country: 'USA'
      }
    })

    order = customer_purchase.generate_order!
  end
end
