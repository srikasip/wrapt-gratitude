module Ec
  class VendorServiceLevel < ApplicationRecord
    belongs_to :vendor
    belongs_to :shipping_service_level, class_name: 'Ec::ShippingServiceLevel'
  end
end
