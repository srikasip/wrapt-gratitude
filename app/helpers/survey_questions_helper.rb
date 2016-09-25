module SurveyQuestionsHelper
  
  def form_fields_partial question
    case question
    when SurveyQuestions::Range then 'range_fields'
    when SurveyQuestions::MultipleChoice then 'multiple_choice_fields'
    when SurveyQuestions::Text then 'text_fields'
    end
  end

  def preview_partial question
    case question
    when SurveyQuestions::Range then 'range_preview'
    when SurveyQuestions::MultipleChoice then 'multiple_choice_preview'
    when SurveyQuestions::Text then 'text_preview'
    end
  end

  def option_list_classes
    if @options.any? {|option| option.image? }
      'multiple-choice--has-images'
    end
  end

  def option_item_classes option
    if option.image?
      'multiple-choice__option--has-image'
    end
  end

end