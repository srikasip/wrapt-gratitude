FactoryGirl.define do
  sequence :cart_id do |n|
    SecureRandom.hex(3)
  end

  factory :shipping_label do
    shippo_object_id "x"*32
    cart_id { generate(:cart_id) }
  end
end
