class ConditionalQuestionOption < ApplicationRecord
  belongs_to :survey_question, required: true
  belongs_to :survey_question_option, required: true
end
