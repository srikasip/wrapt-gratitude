class Gift < ApplicationRecord
  has_many :gift_products, inverse_of: :gift, dependent: :destroy
  has_many :products, through: :gift_products

  has_many :gift_question_impacts, dependent: :destroy
  has_many :evaluation_recommendations, dependent: :destroy

  has_many :gift_images, -> {order :sort_order}, inverse_of: :gift, dependent: :destroy
  has_one :primary_gift_image, -> {where primary: true}, class_name: 'GiftImage'

  # These are implemented as not null in the database
  # so we can treat them as not null for sorting purposese
  # and nullable for display purposes
  DEFAULT_DATE_AVAILABLE = Date.new(1900, 1, 1)
  DEFAULT_DATE_DISCONTINUED = Date.new(2999, 12, 31)

  def available?
    date_available <= Date.today && date_discontinued >= Date.today
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

  def display_date_available format = '%B %-d, %Y'
    (date_available == DEFAULT_DATE_AVAILABLE) ? '' : date_available.strftime(format)
  end

  def display_date_discontinued format = '%B %-d, %Y'
    (date_discontinued == DEFAULT_DATE_DISCONTINUED) ? '' : date_discontinued.strftime(format)
  end

end
