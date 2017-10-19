FactoryGirl.define do
  factory :user, aliases: [:owner] do
    email 'joe@example.com'
    source 'admin_invitation'
  end
end
