class VendorServiceLevel < ApplicationRecord
  belongs_to :vendor
  belongs_to :shipping_service_level
end
