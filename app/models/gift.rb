class Gift < ApplicationRecord
  has_many :gift_products, inverse_of: :gift, dependent: :destroy
  has_many :products, through: :gift_products

  has_many :gift_images, -> {order :sort_order}, inverse_of: :gift, dependent: :destroy

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

  # products available to add to this gift
  def available_products
    Product.where.not(id: gift_products.select(:product_id))
  end

  def name
    title
  end

end
