class Gift < ApplicationRecord
  has_many :gift_products, inverse_of: :gift, dependent: :destroy
  has_many :products, through: :gift_products

  has_many :gift_question_impacts, dependent: :destroy
  has_many :evaluation_recommendations, dependent: :destroy

  has_many :gift_images, -> {order :sort_order}, inverse_of: :gift, dependent: :destroy
  has_one :primary_gift_image, -> {where primary: true}, class_name: 'GiftImage'

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

  def name
    title
  end

end
