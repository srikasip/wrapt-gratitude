module Admin
  module GiftQuestionImpactsHelper

    def edit_body_partial gift_question_impact
      case gift_question_impact.survey_question
      when SurveyQuestions::MultipleChoice then "edit_body_multiple_choice"
      when SurveyQuestions::Range then "edit_body_range"
      end
    end

  end
end