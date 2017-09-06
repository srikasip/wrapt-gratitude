class PurchaseOrder < ApplicationRecord
  has_many :line_items, as: :order
end
