class ProfileSetSurveyResponse < ApplicationRecord
  belongs_to :profile_set

  has_many :question_responses,
    inverse_of: :survey_response,
    class_name: 'SurveyQuestionResponse',
    as: :survey_response,
    dependent: :destroy
  has_many :evaluation_recommendations, dependent: :destroy


  accepts_nested_attributes_for :question_responses, update_only: true

  delegate :survey, :survey_id, to: :profile_set

  before_create :build_question_responses
  def build_question_responses
    profile_set.survey.questions.each do |question|
      question_responses.new survey_question: question
    end
  end

  def question_responses_for_form
    question_responses
      .preload(survey_question: [:survey_section, :options])
      .to_a
      .sort_by do |response|
        [
          response.survey_question.section_or_uncategorized.sort_order,
          response.survey_question.sort_order
        ] 
      end
  end

end