FactoryGirl.define do
  sequence :name do |n|
    "Name#{n}"
  end

  factory :profile do
    first_name { generate(:name) }
    last_name { generate(:name) }
    association :owner

    trait :with_gift_selections do
      after(:create) do |profile|
        gift = FactoryGirl.create(:gift)
        profile.gift_selections.create({
          gift: gift.reload
        })
      end
    end
  end
end
