class SurveyQuestionResponse < ApplicationRecord
  belongs_to :survey_response,
    inverse_of: :question_responses,
    polymorphic: true,
    touch: true
  belongs_to :survey_question

  has_many :survey_question_response_options, inverse_of: :survey_question_response, dependent: :destroy
  has_many :survey_question_options, through: :survey_question_response_options

  validates :text_response, presence: true, if: "survey_question.type == 'SurveyQuestions::Text'", on: :update

  def survey_question_option_id
    survey_question_option_ids.first
  end

  def survey_question_option_id= value
    self.survey_question_option_ids = [value]
  end

  def next_response
    # step = 1
    last_question_index = survey_response.ordered_question_responses.to_a.size - 1
    this_index = survey_response.ordered_question_responses.to_a.index {|response| response.id == id}
    if this_index
      # next_question = survey_response.ordered_question_responses[this_index + step]
      # if next_question.present?
      #   while !next_question.conditions_met?
      #     step += 1
      #     if this_index + step > last_question_index
      #       next_question = nil
      #       break
      #     else
      #       next_question = survey_response.ordered_question_responses[this_index + step]
      #     end
      #   end
      # end
      next_question = find_next_or_prev_with_conditions_met(:next, this_index, last_question_index)
    end
    next_question
  end

  def previous_response
    this_index = survey_response.ordered_question_responses.to_a.index {|response| response.id == id}
    if this_index&.> 0
      # survey_response.ordered_question_responses[this_index - 1]
      prev_question = find_next_or_prev_with_conditions_met(:prev, this_index, 0)
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
          required_response_option_ids = survey_question.conditional_question_options.map(&:survey_question_option_id)
          met = (conditional_question_response_option_ids & required_response_option_ids).size == required_response_option_ids.size
        end
      end
    end
    met
  end

end