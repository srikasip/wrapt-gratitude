class TrainingSetResponseImpact < ApplicationRecord
  belongs_to :training_set_product_question
  belongs_to :survey_question_option
end
