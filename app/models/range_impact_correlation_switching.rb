class RangeImpactCorrelationSwitching
  
  include ActiveModel::Model

  def initialize(training_set_product_question)
    @training_set_product_question = training_set_product_question
  end

  def save
    @training_set_product_question.update range_impact_direct_correlation: !@training_set_product_question.range_impact_direct_correlation
  end

end