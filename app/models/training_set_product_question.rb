class TrainingSetProductQuestion < ApplicationRecord
  belongs_to :training_set
  belongs_to :product
  belongs_to :survey_question
  self.model_name.instance_variable_set(:@route_key, "product_question")
  self.model_name.instance_variable_set(:@singular_route_key, "product_question")

  has_many :response_impacts, class_name: 'TrainingSetResponseImpact', inverse_of: :training_set_product_question, dependent: :destroy
  accepts_nested_attributes_for :response_impacts

  # assumes there are no response impacts
  def create_response_impacts
    survey_question.options.each do |option|
      response_impacts.create survey_question_option: option
    end
  end
end
