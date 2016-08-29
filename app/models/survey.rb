class Survey < ApplicationRecord

  has_many :questions, -> {order 'sort_order asc'}, class_name: 'SurveyQuestion', dependent: :destroy, inverse_of: :survey

  has_many :multiple_choice_questions, class_name: 'SurveyQuestions::MultipleChoice'
  has_many :text_questions, class_name: 'SurveyQuestions::Text'
  has_many :range_questions, class_name: 'SurveyQuestions::Range'

  has_many :profile_sets, inverse_of: :survey, dependent: :destroy
  has_many :training_sets, inverse_of: :survey, dependent: :destroy

end
