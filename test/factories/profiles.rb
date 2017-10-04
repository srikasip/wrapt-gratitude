FactoryGirl.define do
  sequence :name do |n|
    "Person #{n}"
  end

  factory :profile do
    name { generate(:name) }
  end
end
