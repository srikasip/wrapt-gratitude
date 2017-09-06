class PurchaseOrder < ApplicationRecord
  has_many :line_items, as: :order
  belongs_to :customer_order
  belongs_to :vendor
end
