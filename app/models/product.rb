class Product < ApplicationRecord
  belongs_to :product_category, required: true
  belongs_to :product_subcategory, required: true, class_name: 'ProductCategory'

  has_many :gift_products, inverse_of: :product, dependent: :destroy
  has_many :gifts, through: :gift_products

  has_many :product_images, -> {order :sort_order}, inverse_of: :product, dependent: :destroy
  has_one :primary_product_image, -> {where primary: true}, class_name: 'ProductImage'

  belongs_to :vendor, required: true
  belongs_to :source_vendor, required: false, class_name: 'Vendor'
end
