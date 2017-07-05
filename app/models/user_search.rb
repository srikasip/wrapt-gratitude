class UserSearch
  include ActiveModel::Model

  attr_accessor :keyword, :source, :beta_round
  alias_attribute :q, :keyword

  def to_scope
    result = User.all
    result = keyword_filter(result) if keyword.present?
    result = source_filter(result) if source.present?
    result = beta_round_filter(result) if beta_round.present?
    return result
  end
  
  def to_params
    params = {}
    params[:keyword] = keyword if keyword.present?
    params[:beta_round] = beta_round if beta_round.present?
    params[:source] = source if source.present?
    params
  end

  private def keyword_filter scope
    scope.where("LOWER(first_name) LIKE ?", "%#{keyword.downcase}%")
      .or(User.where("LOWER(last_name) LIKE ?", "%#{keyword.downcase}%"))
      .or(User.where("LOWER(email) LIKE ?", "%#{keyword.downcase}%"))
  end

  private def source_filter scope
    scope.where(source: source)
  end
  
  private def beta_round_filter scope
    scope.where(beta_round: beta_round)
  end
  

end