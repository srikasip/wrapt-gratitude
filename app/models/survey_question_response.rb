class SurveyQuestionResponse < ApplicationRecord
  belongs_to :survey_response,
    inverse_of: :question_responses,
    polymorphic: true,
    touch: true
  belongs_to :survey_question

  has_many :survey_question_response_options, inverse_of: :survey_question_response, dependent: :destroy
  has_many :survey_question_options, through: :survey_question_response_options

  attr_accessor :run_front_end_validations
  validates :text_response,
    presence: true,
    if: "run_front_end_validations && survey_question.type == 'SurveyQuestions::Text'",
    on: :update

  after_save :update_profile_relationship
  after_save :update_profile_name

  def attrs_to_copy
    [
      "survey_question_id", 
      "text_response", 
      "range_response", 
      "name", 
      "other_option_text", 
      "survey_response_type"
    ]
  end

  def copy_attributes
    self.dup.attributes.reject{|k, v| !attrs_to_copy.include?(k)}.merge({answered_at: Time.now})
  end

  def copy_option!(option)
    survey_question_response_options.create!(option.copy_attributes)
  end

  def survey
    survey_question.survey
  end

  def survey_question_option_id
    survey_question_option_ids.first
  end

  def survey_question_option_id= value
    self.survey_question_option_ids = [value]
  end

  def next_response
    last_question_index = survey_response.ordered_question_responses.to_a.size - 1
    this_index = survey_response.ordered_question_responses.to_a.index {|response| response.id == id}
    if this_index
      find_next_or_prev_with_conditions_met(:next, this_index, last_question_index)
    end
  end

  def previous_response
    this_index = survey_response.ordered_question_responses.to_a.index {|response| response.id == id}
    if this_index&.> 0
      find_next_or_prev_with_conditions_met(:prev, this_index, 0)
    end
  end

  def find_next_or_prev_with_conditions_met(direction, this_index, last_index)
    step = 1
    index = next_or_prev_index(direction, this_index, step)
    next_or_prev_question = survey_response.ordered_question_responses[index]
    if next_or_prev_question.present?
      while !next_or_prev_question.conditions_met?
        step += 1
        index = next_or_prev_index(direction, this_index, step)
        index_out_of_range = direction == :next ? (index > last_index) : (index < last_index)
        if index_out_of_range
          next_or_prev_question = nil
          break
        else
          next_or_prev_question = survey_response.ordered_question_responses[index]
        end
      end
    end
    next_or_prev_question
  end

  def next_or_prev_index(direction, this_index, step)
    direction == :next ? this_index + step : this_index - step
  end

  def conditions_met?
    met = true
    if survey_question.conditional_question.present?
      if survey_question.conditional_question_options.any?
        conditional_question_response = survey_response.
          question_responses.
          where(survey_question: survey_question.conditional_question).
          first
        if conditional_question_response.present?
          conditional_question_response_option_ids = conditional_question_response.survey_question_response_options.map(&:survey_question_option_id)
          if conditional_question_response_option_ids.present?
            required_response_option_ids = survey_question.conditional_question_options.map(&:survey_question_option_id)
            met = (conditional_question_response_option_ids & required_response_option_ids).size == required_response_option_ids.size
          end
        end
      end
    end
    met
  end

  def to_param
    [id, survey_question.code].
      map(&:to_s).
      map(&:strip).
      select(&:present?).
      map(&:parameterize).
      join('-')
  end

  private def update_profile_relationship
    if survey_question.use_response_as_relationship &&
      survey_response.respond_to?(:profile) &&
      relationship = survey_question_options.first&.text
      then
      survey_response.profile.update_attribute :relationship, relationship
    end
  end

  private def update_profile_name
    if survey_question.use_response_as_name &&
      survey_response.respond_to?(:profile) &&
      name = text_response
      then
      survey_response.profile.update_attribute :first_name, name
    end
  end

end
