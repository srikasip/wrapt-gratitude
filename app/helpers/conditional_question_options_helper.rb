module ConditionalQuestionOptionsHelper
  
  def option_input_checked? option
    @conditional_question_options.any? do 
      |conditional_question_option| conditional_question_option.survey_question_option_id == option.id
    end
  end

  def option_input_name option
    "survey_question[conditional_question_option_option_ids][]"
  end

end