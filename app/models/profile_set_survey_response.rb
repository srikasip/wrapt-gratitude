class ProfileSetSurveyResponse < ApplicationRecord
  belongs_to :profile_set

  has_many :question_responses, inverse_of: :survey_response, class_name: 'SurveyQuestionResponse', dependent: :destroy

  accepts_nested_attributes_for :question_responses, update_only: true

  delegate :survey, to: :profile_set

  def build_question_responses
    profile_set.survey.questions.each do |question|
      question_responses.new survey_question: question
    end
  end

end