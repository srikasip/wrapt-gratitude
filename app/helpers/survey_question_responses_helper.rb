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

  def current_survey_question_number(question_response)
    question_response.survey_question.sort_order
  end

  def question_number_of_total(question_response, survey_questions)
    current_question_number = current_survey_question_number(question_response)
    total_questions = survey_questions.size
    "No #{current_question_number} of #{total_questions}"
  end

  def option_input_data_behavior option
    if option.is_a?(SurveyQuestionOtherOption)
      'option-id-input other-option'
    else
      'option-id-input'
    end
  end

  def survey_questions_progress_bar(survey_response, survey_questions)
    total_questions = survey_questions.size
    answered_questions = survey_response.question_responses.where.not(answered_at: nil).size
    progress = answered_questions == 0 ? 0 : 100/(total_questions.to_f/answered_questions.to_f)
    content_tag :div, class: 'sqr-progress-bar' do
      content_tag :div, '', class: 'sqr-progress-bar__progress', style: "width: #{progress}%;"
    end
  end

  def survey_sections_progress_bar
    "TODO: Section Progress Bar"
  end

end