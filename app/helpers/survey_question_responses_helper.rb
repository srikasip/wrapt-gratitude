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

  def survey_sections_progress_bar(survey_response)
    content_tag :div, class: 'sqr-section-progress-bar' do
      concat content_tag :div, survey_section_icon, class: 'sqr-section-icon__container'
      concat content_tag :div, survey_sections(survey_response, :progress), class: 'sqr-section-progress__container clearfix'
      concat content_tag :div, survey_sections(survey_response, :labels), class: 'sqr-section-label__container clearfix'
    end
  end

  def survey_section_icon
    content_tag :div, class: 'sqr-section-icon__outer' do
      concat content_tag :div, embedded_svg('icon-wrapt-heart', class: 'sqr-section-icon sqr-section-icon__heart'), class: 'sqr-section-icon__inner'
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
          select{|question_response| !question_response&.answered_at.nil? }.
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