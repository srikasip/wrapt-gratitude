module Admin
  class SurveyResponsesController < BaseController
    before_filter :load_survey_response
    
    def show
      @question_responses = @survey_response.question_responses.sort do |a, b|
        [a.survey_question.survey_section&.sort_order.to_i, a.survey_question.sort_order.to_i] <=>
        [b.survey_question.survey_section&.sort_order.to_i, b.survey_question.sort_order.to_i]
      end
      render layout: false
    end
    
    def load_survey_response
      @survey_response = SurveyResponse.preload(
        question_responses: [:survey_question_options, {survey_question: :survey_section}]
      ).where(id: params[:id]).first!
    end
  end
end