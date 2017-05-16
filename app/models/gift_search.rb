class GiftSearch
  include ActiveModel::Model

  attr_accessor :keyword, :product_category_id, :product_subcategory_id,
  :min_price, :max_price, :tags
  alias_attribute :q, :keyword

  def to_scope
    cgf = CalculatedGiftField.arel_table
    result = Gift.all.joins(:calculated_gift_field)
    result = keyword_filter(result) if keyword.present?
    result = product_category_id_filter(result) if product_category_id.present?
    result = product_subcategory_id_filter(result) if product_subcategory_id.present?
    result = min_price_filter(result) if min_price.present?
    result = max_price_filter(result) if max_price.present?
    result = tags_filter(result) if tags.present?
    result = result.order(cgf[:price].asc)
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
  
  private def min_price_filter scope
    cgf = CalculatedGiftField.arel_table
    scope.where(cgf[:price].gteq(min_price))
  end
  
  private def max_price_filter scope
    cgf = CalculatedGiftField.arel_table
    scope.where(cgf[:price].lteq(max_price))
  end
  
  private def tags_filter scope
    @tags = @tags.split(/,\s/).map(&:strip).reject(&:blank?).uniq
    scope.tagged_with(@tags, :any => true)
  end
  

end