class ProductCategory < ApplicationRecord
  acts_as_nested_set
  scope :top_level, -> { where depth: 0 }

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
      "&nbsp;&nbsp;#{name}".html_safe
    end
  end

end
