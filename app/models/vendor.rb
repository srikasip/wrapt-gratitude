class Vendor < ApplicationRecord
  has_many :products, inverse_of: :vendor, dependent: :destroy

end
