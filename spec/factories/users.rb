FactoryGirl.define do
  sequence :user_email do |n|
    "user#{n}@example.com"
  end

  factory :user, aliases: [:owner] do
    email { generate(:user_email) }
    source 'admin_invitation'
  end
end
