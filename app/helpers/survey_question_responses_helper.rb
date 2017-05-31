module SurveyQuestionResponsesHelper

  def response_fields_partial
    case @question_response.survey_question
    when SurveyQuestions::MultipleChoice then multiple_choice_fields_partial
    when SurveyQuestions::Text then 'survey_question_responses/text_fields'
    when SurveyQuestions::Range then 'survey_question_responses/range_fields'
    #TODO yes/no
    end
  end

  def multiple_choice_fields_partial
    if @question_response.survey_question.yes_no_display?
      'survey_question_responses/yes_no_fields'
    else
      'survey_question_responses/multiple_choice_fields'
    end
  end

  def question_response_next_button_text
    if @question_response.next_response
      "Next <svg class='btn__icon-caret-right'><use xlink:href='#icon-caret-right'></use></svg>".html_safe
    else
      'Complete Quiz'
    end
  end

  def question_number_of_total(question_response, survey_response)
    questions = survey_response.
      question_responses_grouped_by_section.
      values.flatten
    "#{questions.index(question_response) + 1} of #{questions.size}"
  end

  def option_input_data_behavior option
    if option.is_a?(SurveyQuestionOtherOption)
      'option-id-input other-option'
    else
      'option-id-input'
    end
  end

  # returns percentage widths for the 4 sections of the survey section progress bar
  # based on total progress through the quiz's initial section (the only one required)
  def survey_section_progress_bar_widths survey_response
    result = []

    question_ids = survey_response.survey.sections.first.questions.pluck(:id)
    answered_question_response_count = survey_response
      .question_responses
      .where(survey_question_id: question_ids)
      .where.not(answered_at: nil)
      .count

    progress = (answered_question_response_count.to_f / question_ids.length.to_f) * 100
    [(0...25), (25...50), (50...75), (75...100)].each do |step_range|
      if progress.in? step_range
        result << ((progress - step_range.begin) / 25) * 100
      elsif progress < step_range.end
        result << 0
      else
        result << 100
      end
    end

    return result
  end


  def other_optional_text_init_style(question_response)
    style = question_response.survey_question_response_options.map{|option| option.survey_question_option.type == 'SurveyQuestionOtherOption'}.any? ? 'display:block;' : 'display:none;'
  end

  def display_section_intro_text?
    if @question_response.survey_question.survey_section.first_in_survey?
      @question_response.survey_question.second_in_section?
    else
      @question_response.survey_question.first_in_section?
    end
  end

end
