class GiftSearch
  include ActiveModel::Model

  attr_accessor :keyword, :product_category_id, :product_subcategory_id
  alias_attribute :q, :keyword

  def to_scope
    result = Gift.all
    result = keyword_filter(result) if keyword.present?
    result = product_category_id_filter(result) if product_category_id.present?
    result = product_subcategory_id_filter(result) if product_subcategory_id.present?
    return result
  end

  private def keyword_filter scope
    scope.where("LOWER(title) LIKE ?", "%#{keyword.downcase}%")
      .or(Gift.where("wrapt_sku LIKE ?", "%#{keyword}%"))
  end

  private def product_category_id_filter scope
    scope.where product_category_id: product_category_id
  end

  private def product_subcategory_id_filter scope
    scope.where product_subcategory_id: product_subcategory_id
  end

end