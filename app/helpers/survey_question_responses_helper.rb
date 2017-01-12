module SurveyQuestionResponsesHelper
  
  def response_fields_partial
    case @question_response.survey_question
    when SurveyQuestions::MultipleChoice then multiple_choice_fields_partial
    when SurveyQuestions::Text then 'text_fields'
    when SurveyQuestions::Range then 'range_fields'
    #TODO yes/no
    end
  end

  def multiple_choice_fields_partial
    if @question_response.survey_question.yes_no_display?
      'yes_no_fields'
    elsif @question_response.survey_question.multiple_option_responses
      'multiple_choice_choose_many_fields'
    else
      'multiple_choice_choose_one_fields'
    end
  end

  def question_response_next_button_text
    if @question_response.next_response
      'Next'
    else
      'Complete Quiz'
    end
  end

  def current_survey_question_number(question_response, survey_questions)
    survey_question = question_response.survey_question
    current_section = survey_question.survey_section
    section_questions = survey_questions.
      where.not(survey_section_id: nil).
      group_by(&:survey_section).
      sort.to_h
    total = 0
    number = 0
    section_questions.each do |section, questions|
      if section.id == current_section.id
        number = total + survey_question.sort_order
      else
        total += questions.size
      end
    end
    number
  end

  def question_number_of_total(question_response, survey_questions)
    current_question_number = current_survey_question_number(question_response, survey_questions)
    total_questions = survey_questions.where.not(survey_section: nil).size
    "No #{current_question_number} of #{total_questions}"
  end

  def option_input_data_behavior option
    if option.is_a?(SurveyQuestionOtherOption)
      'option-id-input other-option'
    else
      'option-id-input'
    end
  end

  def survey_sections_progress_bar
    "TODO: Section Progress Bar"
  end

end