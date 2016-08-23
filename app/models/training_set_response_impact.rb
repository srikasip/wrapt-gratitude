class TrainingSetResponseImpact < ApplicationRecord
  belongs_to :training_set_product_question, inverse_of: :response_impacts, touch: true
  belongs_to :survey_question_option
end
