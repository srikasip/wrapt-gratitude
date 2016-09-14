class Gift < ApplicationRecord
  has_many :gift_products, inverse_of: :gift, dependent: :destroy
  has_many :products, through: :gift_products

  has_many :gift_question_impacts, dependent: :destroy
  has_many :evaluation_recommendations, dependent: :destroy

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
end
