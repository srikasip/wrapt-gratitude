class ShippingServiceLevel < ApplicationRecord
  belongs_to :shipping_carrier

  validates :estimated_days, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :estimated_days, presence: true
  validates :name, presence: true
  validates :shippo_token, presence: true
  validates :terms, presence: true

  def carrier_name
    shipping_carrier.name
  end

  def full_name
    carrier_name + " " + name
  end

  def self.active
    all
  end
end
