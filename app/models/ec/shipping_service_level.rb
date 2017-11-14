module Ec
  class ShippingServiceLevel < ApplicationRecord
    belongs_to :shipping_carrier

    validates :estimated_days, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :estimated_days, presence: true
    validates :name, presence: true
    validates :shippo_token, presence: true
    validates :terms, presence: true

    scope :active, -> { where(active: true) }
    scope :inactive, -> { where(active: false) }

    def carrier_name
      shipping_carrier.name
    end

    def full_name
      carrier_name + " " + name
    end

    def shipping_parcels
      starting_set = shipping_carrier.shipping_parcels

      if shippo_token != 'usps_priority'
        starting_set.where('shippo_template_name is null')
      else
        starting_set
      end
    end

    def self.active
      all
    end
  end
end
