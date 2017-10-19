FactoryGirl.define do
  letters = ('A'..'Z').to_a

  sequence :sku_prefix do |n|
    "#{letters[n%10]}#{letters[n%10]}"
  end

  sequence :email do |n|
    "vendor#{n}@example.com"
  end

  sequence :vendor_name do |n|
    "vendor#{n}"
  end

  factory :vendor do
    wrapt_sku_code { generate(:sku_prefix) }
    phone '123-123-1234'
    email { generate(:email) }
    name { generate(:vendor_name) }
    street1 '14321 Norwood'
    city 'Leawood'
    state 'KS'
    zip '66212'
    country 'US'
  end
end
