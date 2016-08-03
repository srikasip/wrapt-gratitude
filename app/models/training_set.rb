class TrainingSet < ApplicationRecord
  belongs_to :survey

  has_many :product_questions, dependent: :destroy, inverse_of: :training_set
end
