FactoryGirl.define do
  factory :product_category, aliases: [:product_subcategory] do
    wrapt_sku_code { generate(:wrapt_sku) }
  end
end
