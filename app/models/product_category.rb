class ProductCategory < ApplicationRecord
  has_many :products, dependent: :destroy
  has_many :products_as_subcategory, dependent: :destroy, foreign_key: :product_subcategory_id, class_name: 'Product'
  has_many :gifts, dependent: :destroy
  has_many :gifts_as_subcategory, dependent: :destroy, foreign_key: :gift_subcategory_id, class_name: 'Gift'

  acts_as_nested_set
  scope :top_level, -> { where depth: 0 }
  scope :subcategories, -> { where depth: 1 }

  validates :wrapt_sku_code, presence: true, format: {with: /\A[A-Z]{3}\z/, message: 'must be 3 uppercase letters'}
  
  attr_accessor :skus_need_regeneration
  before_save :set_skus_need_regeneration, if: :wrapt_sku_code_changed?
  after_save :regenerate_dependent_skus!, if: :skus_need_regeneration

  # returns an array of all product categories
  # with sub categories following their parent
  def self.all_for_product_form
    [].tap do |result|
      top_level.order(:id).preload(:children).each do |category|
        result << category
        category.children.each do |subcategory|
          result << subcategory
        end
      end
    end
  end

  def name_for_product_form
    if depth == 0
      name
    else
      "&nbsp;&nbsp;&nbsp;&nbsp;#{name}".html_safe
    end
  end

  def top_level?
    depth == 0
  end

  private def set_skus_need_regeneration
    self.skus_need_regeneration = true
  end

  private def regenerate_dependent_skus!
    if top_level?
      relations = [products, gifts]  
    else
      relations = [products_as_subcategory, gifts_as_subcategory]
    end

    relations.each do |relation|
      relation.order(:wrapt_sku).each do |skuable|
        skuable.generate_wrapt_sku
        skuable.save validate: false
      end
    end
  end

end
