class UserSearch
  include ActiveModel::Model

  attr_accessor :keyword
  alias_attribute :q, :keyword

  def to_scope
    result = Product.all
    result = keyword_filter(result) if keyword.present?
    return result
  end

  private def keyword_filter scope
    scope.where("LOWER(first_name) LIKE ?", "%#{keyword.downcase}%")
      .or(User.where("LOWER(last_name) LIKE ?", "%#{keyword.downcase}%"))
      .or(User.where("LOWER(email) LIKE ?", "%#{keyword.downcase}%"))
  end

end