class SurveyResponse < ApplicationRecord
  
  belongs_to :profile
  belongs_to :survey
  has_many :question_responses,
    inverse_of: :survey_response,
    class_name: 'SurveyQuestionResponse',
    dependent: :destroy

  before_create :build_question_responses
  def build_question_responses
    survey.questions.each do |question|
      question_responses.new survey_question: question
    end
  end

end
