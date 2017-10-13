FactoryGirl.define do
  sequence :title do |n|
    "title #{n}"
  end

  sequence :description do |n|
    "description of this thing is thus: #{n}"
  end

  factory :gift do
    title { generate(:title) }
    description { generate(:description) }
    cost 10
    wrapt_sku { generate(:wrapt_sku) }
    available false
    product_category
    product_subcategory

    before(:create) do |gift|
      gift.gift_parcels.build(parcel: Parcel.active.pretty.first)
      gift.gift_parcels.build(parcel: Parcel.active.shipping.first)
      gift.gift_products.build(product: FactoryGirl.create(:product))
    end

    trait :multi_product do
      before(:create) do |gift|
        gift.gift_products.build(product: FactoryGirl.create(:product))
      end
    end
  end
end
