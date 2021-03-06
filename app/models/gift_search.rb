class GiftSearch
  include ActiveModel::Model

  attr_accessor :keyword, :product_category_id, :product_subcategory_id,
  :min_price, :max_price, :tags, :vendor_id, :available
  alias_attribute :q, :keyword

  def to_scope
    cgf = CalculatedGiftField.arel_table
    result = Gift.all.joins(:calculated_gift_field)
    result = keyword_filter(result) if keyword.present?
    result = product_category_id_filter(result) if product_category_id.present?
    result = product_subcategory_id_filter(result) if product_subcategory_id.present?
    result = vendor_id_filter(result) if vendor_id.present?
    result = min_price_filter(result) if min_price.present?
    result = max_price_filter(result) if max_price.present?
    result = tags_filter(result) if tags.present?

    result = \
      case self.available
      when 'Yes' then result.where(available: true)
      when 'No'  then result.where(available: false)
      else
        result
      end

    result = result.order(cgf[:price].asc)
    return result
  end

  private def keyword_filter scope
    t = Gift.arel_table
    scope.where(
      t[:title].matches("%#{keyword}%").or(
      t[:wrapt_sku].matches("%#{keyword}%"))
    )
  end

  private def product_category_id_filter scope
    scope.where product_category_id: product_category_id
  end

  private def vendor_id_filter scope
    scope.where id: GiftProduct.select(:gift_id)
      .joins(:product)
      .where(products: {vendor_id: vendor_id})
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
    @tags = @tags.split(/,|\s/).map(&:strip).reject(&:blank?).uniq
    scope.tagged_with(@tags, :any => true)
  end


end
