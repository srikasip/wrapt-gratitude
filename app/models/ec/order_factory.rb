# Carry a test order from start to finish

module Ec
  module OrderFactory
    NUM_GIFTS = 1
    PROMO_CHANCE = 0.75

    # This is designed to allow a real order on production, but for a dummy gift.
    # Real shipping labels, credit cards, and taxes are involved.
    # OrderFactory.production_test_order!
    def self.production_test_order!
      stripe_token = Stripe::Token.create(
        :card => {
          :number => ENV.fetch('REAL_CC') {'4242424242424242'},
          :exp_month => 8,
          :exp_year => 2018,
          :cvc => ENV.fetch('REAL_CVC') { '123' }
        },
      )

      # Megan is giftee.
      profile = User.find_by(email: 'tblackman@greenriver.com').owned_profiles.find(415)

      customer = profile.owner

      gift = Gift.find_by(title: 'Test Gift', available: false)

      gift.products.first.update_attribute(:units_available, 1)

      desired_gifts = [ PurchaseService::DesiredGift.new(gift, 1) ]

      cart_id = SecureRandom.hex(10)
      puts "cart_id = #{cart_id}"

      customer_purchase = PurchaseService.new({
        cart_id: cart_id,
        customer: customer,
        profile: profile,
        desired_gifts: desired_gifts,
      })

      order = customer_purchase.generate_order!

      # A different page in the shopping process
      customer_purchase = PurchaseService.new(cart_id: cart_id)
      customer_purchase.gift_wrapt!(
        ActionController::Parameters.new({ customer_order: {
          gift_wrapt: ['1', '0'].sample,
          include_note: '1',
          note_content: "Vivamus magna justo, lacinia eget consectetur sed,\nconvallis at tellus. Pellentesque in ipsum id orci porta dapibus.\n Praesent sapien massa, convallis a pellentesque nec, egestas non nisi.\n Vestibulum ante ipsum primis in faucibus orci luctus et ultrices\n posuere cubilia Curae; Donec velit neque, auctor sit amet aliquam vel,\n ullamcorper sit amet ligula. Curabitur arcu erat, accumsan id\n imperdiet et, porttitor at sem. Praesent sapien massa, convallis a\n pellentesque nec, egestas non nisi. Lorem ipsum dolor sit amet,\n consectetur adipiscing elit. Curabitur non nulla sit amet nisl tempus\n convallis quis ac lectus. Vivamus suscipit tortor eget felis porttitor\n volutpat. Praesent sapien massa, convallis a pellentesque nec, egestas\n non nisi.  Sed porttitor lectus nibh. Praesent sapien massa, convallis\n a pellentesque nec, egestas non nisi. Curabitur arcu erat, accumsan id\n imperdiet et, porttitor at sem. Vestibulum ac diam sit amet quam\n vehicula elementum sed sit amet dui. Nulla porttitor accumsan\n tincidunt. Cras ultricies ligula sed magna dictum porta. Vivamus\n suscipit tortor eget felis porttitor volutpat. Donec sollicitudin\n molestie malesuada. Lorem ipsum dolor sit amet, consectetur adipiscing\n elit. Donec rutrum congue leo eget malesuada."
        }})
      )

      # A different page in the shopping process
      customer_purchase = PurchaseService.new(cart_id: cart_id)
      customer_purchase.set_address!(
        ActionController::Parameters.new({customer_order: {
          ship_street1: '4194 West 25 North',
          ship_street2: '',
          ship_city: 'Cedar City',
          ship_state: 'UT',
          ship_zip: '84720',
          ship_country: 'US',
          email: 'meborn@greenriver.com',
        }})
      )

      _ = customer_purchase.shipping_choices_for_view

      # A difference virtual page load in the shopping process
      customer_purchase = PurchaseService.new(cart_id: cart_id)
      customer_purchase.pick_shipping!('cheapest')

      # A different virtual page load in the shopping process
      customer_purchase = PurchaseService.new(cart_id: cart_id)
      params = ActionController::Parameters.new({stripeToken: stripe_token.id, 'address-zip'.to_sym => '05301'})
      customer_purchase.init_our_charge_record!(params)

      # A different virtual page load in the shopping process
      customer_purchase = PurchaseService.new(cart_id: cart_id)
      customer_purchase.authorize!

      order.reload

      puts order.ai

      order
    end

    def self.create_order!(auto_ack:, gifts:nil)
      raise "NEVER ON PRODUCTION" if Rails.env.production?

      Vendor.update_all("email = 'apple@example.com,pickle@gmail.com ; fudge@foo.org ,  nobody@nowhere.net'")

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

        Profile.where('first_name is null').update_all("first_name = 'Karen'")

        Gift.preload(:gift_parcels => :gift).find_each do |gift|
          if gift.pretty_parcel.blank?
            gift.gift_parcels.create(parcel: Parcel.active.where(usage: 'pretty').first)
          end
          if gift.shipping_parcel.blank?
            gift.gift_parcels.create(parcel: Parcel.active.where(usage: 'shipping').first)
          end
        end

      end

      good_cards = [
        '4242424242424242', # Visa
        '4000056655665556', # Visa (debit)
        '5555555555554444', # Mastercard
        '5200828282828210', # Mastercard (debit)
        '5105105105105100', # Mastercard (prepaid)
        '378282246310005',  # American Express
        '371449635398431',  # American Express
        '6011111111111117', # Discover
        '6011000990139424', # Discover
        '30569309025904',   # Diners Club
        '38520000023237',   # Diners Club
        '3530111333300000', # JCB
      ]

      failures = [
        '4000000000000077', # Charge succeeds and funds will be added directly to your available balance (bypassing your pending balance).
        '4000000000000093', # Charge succeeds and domestic pricing is used (other test cards use international pricing). This card is only significant in countries with split pricing.
        '4000000000000010', # The address_line1_check and address_zip_check verifications fail. If your account is blocking payments that fail ZIP code validation, the charge is declined.
        '4000000000000028', # Charge succeeds but the address_line1_check verification fails.
        '4000000000000036', # The address_zip_check verification fails. If your account is blocking payments that fail ZIP code validation, the charge is declined.
        '4000000000000044', # Charge succeeds but the address_zip_check and address_line1_check verifications are both unavailable.
        '4000000000000101', # If a CVC number is provided, the cvc_check fails. If your account is blocking payments that fail CVC code validation, the charge is declined.
        '4000000000000341', # Attaching this card to a Customer object succeeds, but attempts to charge the customer fail.
        '4000000000009235', # Charge succeeds with a risk_level of elevated and placed into review.
        '4000000000000002', # Charge is declined with a card_declined code.
        '4100000000000019', # Results in a charge with a risk level of highest. The charge is blocked as it's considered fraudulent.
        '4000000000000127', # Charge is declined with an incorrect_cvc code.
        '4000000000000069', # Charge is declined with an expired_card code.
        '4000000000000119', # Charge is declined with a processing_error code.
        '4242424242424241', # Charge is declined with an incorrect_number code as the card number fails the Luhn check.
      ]

      # Fail some of the time for testing.
      stripe_token = \
        if Random.rand > 0.05
          Stripe::Token.create(
            :card => {
              :number => good_cards.sample,
              :exp_month => 8,
              :exp_year => Date.today.year+1,
              :cvc => "314"
            },
          )
        else
          Stripe::Token.create(
            :card => {
              :number => failures.sample,
              :exp_month => 8,
              :exp_year => Date.today.year+1,
              :cvc => "314"
            },
          )
        end

      profile = Profile.order('random()').first

      if ENV['USER'] == 'blackman'
        profile = User.find_by(email: 'tblackman@greenriver.com').owned_profiles.sample
      end

      customer = profile.owner

      if gifts.nil?
        gifts = Gift.order('random()').first(NUM_GIFTS)
      end

      desired_gifts = gifts.map do |gift|
        # Can only buy one at a time right now given what I see in the mocks.
        DesiredGift.new(gift, 1)
      end

      cart_id = SecureRandom.hex(10)

      customer_purchase = PurchaseService.new({
        cart_id: cart_id,
        customer: customer,
        profile: profile,
        desired_gifts: desired_gifts,
      })

      order = customer_purchase.generate_order!

      # A different page in the shopping process
      customer_purchase = PurchaseService.new(cart_id: cart_id)
      customer_purchase.gift_wrapt!(
        ActionController::Parameters.new({ ec_customer_order: {
          gift_wrapt: ['1', '0'].sample,
          include_note: ['1', '0'].sample,
          note_content: "Vivamus magna justo, lacinia eget consectetur sed, convallis at tellus. Pellentesque in ipsum id orci porta dapibus. Praesent sapien massa, convallis a pellentesque nec, egestas non nisi. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec velit neque, auctor sit amet aliquam vel, ullamcorper sit amet ligula. Curabitur arcu erat, accumsan id imperdiet et, porttitor at sem. Praesent sapien massa, convallis a pellentesque nec, egestas non nisi. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur non nulla sit amet nisl tempus convallis quis ac lectus. Vivamus suscipit tortor eget felis porttitor volutpat. Praesent sapien massa, convallis a pellentesque nec, egestas non nisi.  Sed porttitor lectus nibh. Praesent sapien massa, convallis a pellentesque nec, egestas non nisi. Curabitur arcu erat, accumsan id imperdiet et, porttitor at sem. Vestibulum ac diam sit amet quam vehicula elementum sed sit amet dui. Nulla porttitor accumsan tincidunt. Cras ultricies ligula sed magna dictum porta. Vivamus suscipit tortor eget felis porttitor volutpat. Donec sollicitudin molestie malesuada. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec rutrum congue leo eget malesuada."
        }})
      )

      again = true
      while(again) do
        # A different page in the shopping process
        customer_purchase = PurchaseService.new(cart_id: cart_id)
        customer_purchase.set_address!(
          ActionController::Parameters.new({ec_customer_order: {
            ship_street1: '1990 M St NW',
            ship_street2: "Unit #{Random.rand(9000)}",
            ship_city: 'Washington',
            ship_zip: '20036',
            ship_state: 'DC',
            ship_country: 'US',
            email: 'example@example.com',
          }})
        )

        # usps only since I haven't yet developed the logic for handling shipping
        # across all the choices/vendors/pos to be consistent yet. usps options are always
        # choices, so they're safe.
        #choices = customer_purchase.shipping_choices_for_view
        #picked_choice = choices.sample

        # A different virtual page load in the shopping process
        customer_purchase = PurchaseService.new(cart_id: cart_id)
        #customer_purchase.pick_shipping!(picked_choice.value)
        customer_purchase.pick_shipping!('cheapest')

        # A different virtual page load in the shopping process
        customer_purchase = PurchaseService.new(cart_id: cart_id)

        if Random.rand > (1 - PROMO_CHANCE)
          promo_code = PromoCode.create!({
            value: SecureRandom.hex(5),
            description: 'auto',
            start_date: Date.yesterday,
            end_date: Date.tomorrow,
            amount: Random.rand(10)+1,
            mode: PromoCode::MODES.sample
          })
          co = customer_purchase.customer_order
          co.set_promo_code(promo_code)
          co.save!
        end

        params = ActionController::Parameters.new({stripeToken: stripe_token.id, 'address-zip'.to_sym => '66212'})
        customer_purchase.init_our_charge_record!(params)

        # Simulate going back and changing things
        if Random.rand > 0.5
          again = false
        end
      end

      # A different virtual page load in the shopping process (finalize step)
      customer_purchase = Ec::PurchaseService.new(cart_id: cart_id)
      customer_purchase.authorize!

      unless customer_purchase.card_authorized?
        return order
      end

      # All the vendors acknowledge via emails and click-through to a page where they say it's okay.
      # This simulates that 99.5% of the time, a purchase order will be fulfillable.
      if auto_ack
        order.purchase_orders.each do |po|
          po.vendor_acknowledgement_status = Random.rand > 0.005 ? PurchaseOrder::FULFILL : PurchaseOrder::DO_NOT_FULFILL
          po.save!
        end
      end

      # This happens when a vendor confirms they have inventory
      customer_purchase = PurchaseService.new(cart_id: cart_id)
      customer_purchase.update_from_vendor_responses!

      order
    end
  end
end
