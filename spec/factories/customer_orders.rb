FactoryGirl.define do
  sequence :shippo_object_id do |n|
    SecureRandom.hex(16)
  end

  factory :customer_order do
    ship_street1 "10109 Floyd"
    ship_city "Overland Park"
    ship_state "KS"
    ship_zip "66212"
    ship_country "US"
    recipient_name { generate(:name) }

    cart_id { SecureRandom.hex(3) }

    association :user
    association :profile

    after(:create) do |customer_order, evaluator|
      FactoryGirl.create :purchase_order, customer_order: customer_order
    end

    trait :with_one_gift do
      after(:create) do |customer_order, evaluator|
        customer_order.line_items.create({
          orderable: FactoryGirl.create(:gift),
          quantity: 1
        })
      end
    end

    trait :with_shipping_label do
      after(:create) do |customer_order, evaluator|
        shipment = FactoryGirl.create :shipment, customer_order: customer_order, purchase_order: customer_order.purchase_orders.first, cart_id: customer_order.cart_id

        FactoryGirl.create :shipping_label, \
          shippo_object_id: "8023f999c99149d08212a6dc1f15f1f4",
          shipment: shipment,
          customer_order: customer_order,
          purchase_order: customer_order.purchase_orders.first
      end
    end
  end
end
