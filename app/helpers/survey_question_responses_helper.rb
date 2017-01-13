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

  def question_number_of_total(question_response, survey_response)
    questions = survey_response.
      question_responses_grouped_by_section.
      values.flatten
    "No #{questions.index(question_response) + 1} of #{questions.size}"
  end

  def option_input_data_behavior option
    if option.is_a?(SurveyQuestionOtherOption)
      'option-id-input other-option'
    else
      'option-id-input'
    end
  end

  def survey_sections_progress_bar(survey_response)
    content_tag :div, class: 'sqr-section-progress-bar' do
      concat content_tag :div, survey_section_icon, class: 'sqr-section-icon__container'
      concat content_tag :div, survey_sections(survey_response, :progress), class: 'sqr-section-progress__container clearfix'
      concat content_tag :div, survey_sections(survey_response, :labels), class: 'sqr-section-label__container clearfix'
    end
  end

  def survey_section_icon
    content_tag :div, class: 'sqr-section-icon__outer' do
      concat content_tag :div, embedded_svg('icon-wrapt-heart', class: 'sqr-section-icon'), class: 'sqr-section-icon__inner'
    end
  end

  def survey_sections(survey_response, display)
    section_question_responses = survey_response.question_responses_grouped_by_section
    section_groups = section_question_responses.keys.in_groups(2, false)
    render "survey_section", section_groups: survey_section_data(section_question_responses), display: display
  end

  def survey_section_data(section_question_responses)
    section_groups = section_question_responses.keys.in_groups(2, false)
    section_groups_data = []
    section_groups.each_with_index do |section_group, index|
      group_data = []
      section_group.each do |section|
        section_width = 100/section_group.size
        questions = section_question_responses[section]
        answered_questions_size = questions.
          select{|question_response| !question_response.answered_at.nil? }.
          size
        progress_width = answered_questions_size > 0 ? 100/(questions.size/answered_questions_size.to_f) : 0
        section_data = {
          section_name: section.name,
          section_width: section_width, 
          progress_width: progress_width,
        }
        group_data << section_data
      end
      section_groups_data << group_data
    end
    section_groups_data
  end

end