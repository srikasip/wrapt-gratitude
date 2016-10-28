class TraitTrainingSet < ApplicationRecord
  # Training relationships for personality traits
  belongs_to :survey

  has_many :trait_training_set_questions, dependent: :destroy, inverse_of: :trait_training_set


  def refresh_questions!
    survey.questions.each do |question|
      trait_training_set_questions.where(question_id: question.id).first_or_create 
    end
  end
end
