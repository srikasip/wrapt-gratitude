class Product < ApplicationRecord
  mount_uploader :image, ProductImageUploader
  has_and_belongs_to_many :product_categories
end
