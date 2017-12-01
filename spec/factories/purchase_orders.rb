FactoryGirl.define do
  factory :purchase_order, class: Ec::PurchaseOrder do
    order_number { Ec::InternalOrderNumber.next_val }
  end
end
