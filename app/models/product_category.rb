class ProductCategory < ApplicationRecord
  acts_as_nested_set
  scope :top_level, -> {where depth: 0}
end
