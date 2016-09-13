class Product < ApplicationRecord
  mount_uploader :image, ProductImageUploader
  has_and_belongs_to_many :product_categories

  has_many :training_set_product_questions, dependent: :destroy
  has_many :evaluation_recommendations, dependent: :destroy
end
