class ShippingCarrier < ApplicationRecord
  has_many :shipping_service_levels, dependent: :destroy

  validates :shippo_provider_name, presence: true
  validates :name, presence: true
end
