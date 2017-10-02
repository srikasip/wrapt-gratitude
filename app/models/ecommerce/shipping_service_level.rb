class ShippingServiceLevel < ApplicationRecord
  belongs_to :shipping_carrier

  validates :estimated_days, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :estimated_days, presence: true
  validates :name, presence: true
  validates :shippo_token, presence: true
  validates :terms, presence: true
end
