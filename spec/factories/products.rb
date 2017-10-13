FactoryGirl.define do
  letters = ('A'..'Z').to_a

  sequence :wrapt_sku do |n|
    "#{letters[n%10]}#{letters[n%10]}#{letters[n%10]}"
  end

  factory :product do
    description { generate(:description) }
    wrapt_cost 10
    price 10
    wrapt_sku { generate(:wrapt_sku) }
    vendor
    weight_in_pounds 2
    product_category
    product_subcategory
  end
end
