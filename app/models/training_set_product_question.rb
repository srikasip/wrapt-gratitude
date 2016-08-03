class TrainingSetProductQuestion < ApplicationRecord
  belongs_to :training_set
  belongs_to :product
  belongs_to :question, class_name: 'SurveyQuestion'
end
