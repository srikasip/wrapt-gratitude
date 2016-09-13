class Gift < ApplicationRecord
  has_many :gift_products, inverse_of: :gift, dependent: :destroy
  has_many :products, through: :gift_products

  def available?
    date_available >= Date.today && date_discontinued <= Date.today
  end

  def availability_string
    if available?
      "Available"
    else
      "Not available"
    end
  end
end
