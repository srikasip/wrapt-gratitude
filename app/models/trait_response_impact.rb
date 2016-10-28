class TraitResponseImpact < ApplicationRecord
  belongs_to :trait_training_set_question
  belongs_to :survey_question_option, required: false
end
