class SurveyQuestion < ApplicationRecord
  belongs_to :survey, inverse_of: :questions
  has_many :options, inverse_of: :question, dependent: :destroy, class_name: 'SurveyQuestionOption'

  has_many :training_set_product_questions, dependent: :destroy
end
