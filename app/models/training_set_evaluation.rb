class TrainingSetEvaluation < ApplicationRecord
  belongs_to :training_set

  has_many :recommendations, class_name: 'EvaluationRecommendation', dependent: :destroy

  def profile_sets
    training_set.survey.profile_sets
  end
end
