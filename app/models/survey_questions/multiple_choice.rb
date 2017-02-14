module SurveyQuestions
  class MultipleChoice < ::SurveyQuestion

    has_one :other_option, class_name: 'SurveyQuestionOtherOption', foreign_key: 'survey_question_id'
    after_save :create_or_destroy_other_option_if_flag_changed

    def type_label
      "Multiple Choice"
    end

    private def create_or_destroy_other_option_if_flag_changed
      if include_other_option_changed?
        if include_other_option? && other_option.blank?
          create_other_option!
        else
          other_option.destroy!
        end
      end
    end

    def use_multiple_response_form?
      multiple_option_responses && !yes_no_display
    end
    

  end
end