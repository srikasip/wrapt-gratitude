module SurveyQuestions
  class Text < ::SurveyQuestion

    after_save :ensure_unique_use_response_as_name

    def use_secondary_prompt?
      false
    end

    def type_label
      "Text"
    end

    def ensure_unique_use_response_as_name
      if use_response_as_name? && use_response_as_name_changed?
        survey.questions.where.not(id: id).update_all use_response_as_name: false
      end
    end

  end
end