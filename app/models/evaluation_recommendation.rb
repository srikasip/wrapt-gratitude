class EvaluationRecommendation < ApplicationRecord
  belongs_to :survey_response, class_name: 'ProfileSetSurveyResponse', foreign_key: :profile_set_survey_response_id
  belongs_to :product
  belongs_to :training_set_evaluation
end
