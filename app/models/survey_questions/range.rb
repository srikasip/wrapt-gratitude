module SurveyQuestions
  class Range < ::SurveyQuestion

    validates :min_label, :max_label, presence: true, on: :update

    def type_label
      "Slider"
    end

    def system_type_label
      "range"
    end
    

  end
end