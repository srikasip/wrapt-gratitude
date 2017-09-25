FactoryGirl.define do
  factory :user do
    email 'joe@example.com'
    source 'admin_invitation'
  end
end
