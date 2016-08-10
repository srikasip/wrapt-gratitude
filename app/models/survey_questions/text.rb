module SurveyQuestions
  class Text < ::SurveyQuestion

    def use_secondary_prompt?
      false
    end

    def type_label
      "Text"
    end

  end
end