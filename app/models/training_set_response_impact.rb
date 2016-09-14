class TrainingSetResponseImpact < ApplicationRecord
  belongs_to :gift_question_impact, inverse_of: :response_impacts, touch: true
  belongs_to :survey_question_option
end
