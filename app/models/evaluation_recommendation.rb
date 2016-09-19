class EvaluationRecommendation < ApplicationRecord
  belongs_to :survey_response, class_name: 'ProfileSetSurveyResponse', foreign_key: :profile_set_survey_response_id
  belongs_to :gift
  belongs_to :training_set_evaluation

  delegate :training_set, to: :training_set_evaluation
end
