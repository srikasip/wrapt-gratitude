class Gift < ApplicationRecord
  has_many :gift_products, inverse_of: :gift, dependent: :destroy
  has_many :products, through: :gift_products


  has_many :gift_question_impacts, dependent: :destroy
  has_many :evaluation_recommendations, dependent: :destroy
  has_many :survey_responses, dependent: :destroy
  has_many :gift_selections, dependent: :destroy

  has_many :gift_images, -> {order :sort_order}, inverse_of: :gift, dependent: :destroy
  has_many :uploaded_gift_images, class_name: 'GiftImages::Uploaded'
  has_many :gift_images_from_products, class_name: 'GiftImages::FromProduct'

  has_one :primary_gift_image, -> {where primary: true}, class_name: 'GiftImage'

  belongs_to :source_product, class_name: 'Product', required: false

  belongs_to :product_category, required: true
  belongs_to :product_subcategory, required: true, class_name: 'ProductCategory'

  before_save :generate_wrapt_sku, if: :sku_needs_updating?

  # These are implemented as not null in the database
  # so we can treat them as not null for sorting purposese
  # and nullable for display purposes
  DEFAULT_DATE_AVAILABLE = Date.new(1900, 1, 1)
  DEFAULT_DATE_DISCONTINUED = Date.new(2999, 12, 31)

  def self.search search_params
    self.all.merge(GiftSearch.new(search_params).to_scope)        
  end

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

  def cost
    if calculate_cost_from_products?
      products.sum(:wrapt_cost)
    else
      super
    end
  end

  def selling_price
    if calculate_price_from_products?
      products.sum(:price)
    else
      super
    end
  end

  private def sku_prefix
    segments = []
    segments << "G"

    vendor_sku = vendor_product&.vendor&.wrapt_sku_code.presence || "XX"
    segments << vendor_sku

    category_sku = product_category&.wrapt_sku_code.presence || "XXX"
    segments << category_sku

    subcategory_sku = product_subcategory&.wrapt_sku_code.presence || "XXX"
    segments << subcategory_sku

    segments.join("-")
  end

  def sku_unique_id
    wrapt_sku.split('-').last
  end

  def generate_wrapt_sku
    others_with_prefix = Gift.where("wrapt_sku LIKE ?", "#{sku_prefix}%")
    last_sku_unique_id = others_with_prefix.order(:wrapt_sku).last&.sku_unique_id || "000"
    next_sku_unique_id = format "%03d", (last_sku_unique_id.to_i + 1)

    self.wrapt_sku = "#{sku_prefix}-#{next_sku_unique_id}"
  end

  def generate_wrapt_sku! **save_opts
    generate_wrapt_sku
    save({validate: false}.merge save_opts)
  end

  private def sku_needs_updating?
    product_category_id_changed? ||
    product_subcategory_id_changed?
  end

  def vendor_product
    products.first
  end

  def self.default_product_category
    ProductCategory.where(wrapt_sku_code: 'GFT').first_or_create!(name: 'Gift')
  end

  def single_product_gift?
    source_product_id.present?
  end

  def primary_gift_image_with_fallback
    primary_gift_image || gift_images.first
  end

end
