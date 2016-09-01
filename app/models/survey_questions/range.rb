module SurveyQuestions
  class Range < ::SurveyQuestion

    validates :min_label, :max_label, presence: true, on: :update

    def type_label
      "Slider"
    end
    

  end
end