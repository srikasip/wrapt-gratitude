class ProfileSetSurveyResponse < ApplicationRecord
  belongs_to :profile_set

  has_many :question_responses, -> {joins(survey_question: :survey_section).order('survey_sections.sort_order ASC, survey_questions.sort_order ASC')}, inverse_of: :survey_response, class_name: 'SurveyQuestionResponse', dependent: :destroy
  has_many :evaluation_recommendations, dependent: :destroy


  accepts_nested_attributes_for :question_responses, update_only: true

  delegate :survey, :survey_id, to: :profile_set

  def build_question_responses
    profile_set.survey.questions.each do |question|
      question_responses.new survey_question: question
    end
  end

end