class GiftQuestionImpact < ApplicationRecord
  belongs_to :training_set, touch: true, inverse_of: :gift_question_impacts, required: true
  belongs_to :gift, required: true
  belongs_to :survey_question, required: true
  self.model_name.instance_variable_set(:@route_key, "gift_question")
  self.model_name.instance_variable_set(:@singular_route_key, "gift_question")

  has_many :response_impacts, class_name: 'TrainingSetResponseImpact', inverse_of: :gift_question_impact, dependent: :destroy
  accepts_nested_attributes_for :response_impacts

  # TODO get this working correctly
  # validate :validate_unique_question_for_product, if: -> {product && survey_question}, on: :create

  # assumes there are no response impacts
  def create_response_impacts
    survey_question.options.each do |option|
      response_impacts.create survey_question_option: option
    end
  end

  def validate_unique_question_for_product
    if training_set.product_questions.where(survey_question_id: survey_question_id, product_id: product_id)
      errors.add :survey_question, "Already exists for this product in this training set"
    end
  end  

end
