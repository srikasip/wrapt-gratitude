class GiftProduct < ApplicationRecord
  belongs_to :gift, inverse_of: :gift_products, required: true
  belongs_to :product, inverse_of: :gift_products, required: true
end
