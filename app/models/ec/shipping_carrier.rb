module Ec
  class ShippingCarrier < ApplicationRecord
    has_many :shipping_service_levels, dependent: :destroy

    validates :shippo_provider_name, presence: true
    validates :name, presence: true

    scope :active, -> { where(active: true) }

    def shipping_parcels
      if self.name == 'USPS'
        Parcel.shipping
      else
        # USPS currently is only one with templates, so filter those out when not
        # USPS
        Parcel.shipping.where('shippo_template_name is null')
      end
    end
  end
end
