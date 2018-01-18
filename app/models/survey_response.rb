class SurveyResponse < ApplicationRecord

  belongs_to :profile
  belongs_to :survey
  has_many :question_responses,
    inverse_of: :survey_response,
    class_name: 'SurveyQuestionResponse',
    as: :survey_response,
    dependent: :destroy

  accepts_nested_attributes_for :question_responses

  scope :completed, -> { where.not(completed_at: nil) }
  scope :incomplete, -> { where(completed_at: nil) }

  before_create :build_question_responses
  def build_question_responses
    survey.questions.each do |question|
      question_responses.new survey_question: question
    end
  end

  # Get a list of question resonses in the order they appear in the survey
  def ordered_question_responses
    result = []
    survey.sections.includes(:questions).each do |section|
      section.questions.each do |question|
        result << question_responses.detect {|question_response| question_response.survey_question_id == question.id}
      end
    end
    return result.compact
  end

  # hash of questions grouped by section
  # conditional questions included if conditions are met
  def question_responses_grouped_by_section
    results = {}
    survey.sections.includes(:questions).each do |section|
      questions = section.questions
      if questions.present?
        results[section] = []
        questions.each do |question|
          question_response = question_responses.where(survey_question_id: question.id).first
          if question_response.present? && question_response.conditions_met?
            results[section] << question_response
          end
        end
      end
    end
    return results
  end

  def last_answered_response
    ordered_question_responses.select{|response| response.answered_at.present?}.last || ordered_question_responses.first
  end

  def first_unanswered_response
    ordered_question_responses.find do |response|
      response.answered_at.blank?
    end
  end

  def giftee_name
    if name_question = survey.name_question
      return question_responses
        .where(survey_question: name_question)
        .first
        &.text_response
        .presence
    end
  end

end
