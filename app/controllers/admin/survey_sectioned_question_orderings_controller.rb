module Admin
  class SurveySectionedQuestionOrderingsController < BaseController

    respond_to :json

    def create
      @survey = Survey.find params[:survey_id]
      @sectioned_ordering = SurveySectionedQuestionOrdering.new survey: @survey, sections_attributes: create_params[:sections]
      @sectioned_ordering.save
      head :ok
    end

    def create_params
      params.permit(sections: [:id, {question_ordering: []}])
    end

  end
end