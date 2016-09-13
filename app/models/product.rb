class Product < ApplicationRecord
  mount_uploader :image, ProductImageUploader
  has_and_belongs_to_many :product_categories

  has_many :training_set_product_questions, dependent: :destroy
  has_many :evaluation_recommendations, dependent: :destroy

  has_many :gift_products, inverse_of: :product, dependent: :destroy
  has_many :gifts, through: :gift_products
end
