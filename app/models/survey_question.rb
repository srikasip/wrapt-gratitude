class SurveyQuestion < ApplicationRecord
  # abstract base class for survey questions
  belongs_to :survey, inverse_of: :questions
  has_many :training_set_product_questions, dependent: :destroy

  # type-specific associations are on the base class for preloading
  has_many :options, inverse_of: :question, dependent: :destroy, class_name: 'SurveyQuestionOption'

  has_many :survey_question_responses, dependent: :destroy

  def use_secondary_prompt?
    true
  end
end