class Survey < ApplicationRecord

  has_many :questions, class_name: 'SurveyQuestion', dependent: :destroy, inverse_of: :survey

  has_many :multiple_choice_questions, class_name: 'SurveyQuestions::MultipleChoice'
  has_many :text_questions, class_name: 'SurveyQuestions::Text'

end
