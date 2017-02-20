class GiftSearch
  include ActiveModel::Model

  attr_accessor :keyword, :product_category_id, :product_subcategory_id,
  :min_price, :max_price
  alias_attribute :q, :keyword

  def to_scope
    result = Gift.all
    result = keyword_filter(result) if keyword.present?
    result = product_category_id_filter(result) if product_category_id.present?
    result = product_subcategory_id_filter(result) if product_subcategory_id.present?
    result = min_price_filter(result) if min_price.present?
    result = max_price_filter(result) if max_price.present?
    result = result.order("#{calculated_price_sql} asc")
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
    scope.where("#{calculated_price_sql} >= ?", min_price)
  end
  
  private def max_price_filter scope
    scope.where("#{calculated_price_sql} <= ?", max_price)
  end
  
  private def calculated_price_sql
    %{case when calculate_price_from_products then
      (
        select sum(products.price) from gift_products
        join products on gift_products.product_id = products.id
        where gift_products.gift_id = gifts.id
      )
      else
        selling_price
      end
    }
  end

end