class Product < ApplicationRecord
  validates :price, numericality: { greater_than: 0.00 }
  validates :description, length: { minimum: 10 }
  validates :units_available, numericality: { only_integer: true }
  validates :wrapt_cost, numericality: {  greater_than: 0.00 }

  belongs_to :product_category, required: true
  belongs_to :product_subcategory, required: true, class_name: 'ProductCategory'

  has_many :gift_products, inverse_of: :product, dependent: :destroy
  has_many :gifts, through: :gift_products

  has_many :product_images, -> {order :sort_order}, inverse_of: :product, dependent: :destroy
  has_one :primary_product_image, -> {where primary: true}, class_name: 'ProductImage'

  belongs_to :vendor, required: true
  belongs_to :source_vendor, required: false, class_name: 'Vendor'

  before_save :generate_wrapt_sku, if: :sku_needs_updating?

  has_one :single_product_gift, class_name: 'Gift', foreign_key: :source_product_id, inverse_of: :source_product, dependent: :destroy

  attr_accessor :dependent_skus_need_regeneration
  before_save :set_dependent_skus_need_regeneration, if: :vendor_id_changed?
  after_save :regenerate_dependent_skus!, if: :dependent_skus_need_regeneration

  before_destroy -> { raise "Cannot destroy" unless deleteable? }

  def self.search search_params
    self.all.merge(ProductSearch.new(search_params).to_scope)
  end

  def deleteable?
    LineItem.where(orderable: self).none?
  end

  private def sku_prefix
    segments = []
    segments << "P"

    vendor_sku = vendor&.wrapt_sku_code.presence || "XX"
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
    others_with_prefix = Product.where("wrapt_sku LIKE ?", "#{sku_prefix}%")
    last_sku_unique_id = others_with_prefix.order(:wrapt_sku).last&.sku_unique_id || "000"
    next_sku_unique_id = format "%03d", (last_sku_unique_id.to_i + 1)

    self.wrapt_sku = "#{sku_prefix}-#{next_sku_unique_id}"
  end

  def generate_wrapt_sku! **save_opts
    generate_wrapt_sku
    save({validate: false}.merge save_opts)
  end

  private def sku_needs_updating?
    vendor_id_changed? ||
    product_category_id_changed? ||
    product_subcategory_id_changed?
  end

  private def set_dependent_skus_need_regeneration
    self.dependent_skus_need_regeneration = true
  end

  def regenerate_dependent_skus!
    gifts.preload(:products).each do |gift|
      if gift.vendor_product == self
        gift.generate_wrapt_sku
        gift.save validate: false
      end
    end
  end
end
