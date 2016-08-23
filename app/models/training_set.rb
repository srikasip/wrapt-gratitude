class TrainingSet < ApplicationRecord
  belongs_to :survey

  has_many :product_questions, dependent: :destroy, inverse_of: :training_set, class_name: 'TrainingSetProductQuestion'

  has_one :evaluation, class_name: 'TrainingSetEvaluation', dependent: :destroy, inverse_of: :training_set
end
