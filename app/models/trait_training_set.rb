class TraitTrainingSet < ApplicationRecord
  # Training relationships for personality traits
  belongs_to :survey

  has_many :trait_training_set_questions, dependent: :destroy, inverse_of: :trait_training_set
  has_many :evaluations, dependent: :destroy, class_name: 'SurveyResponseTraitEvaluation'

  def refresh_questions!
    # TODO exclude text questions
    survey.questions.not_text.each do |question|
      trait_training_set_questions.where(question_id: question.id).first_or_create 
    end
  end
end
