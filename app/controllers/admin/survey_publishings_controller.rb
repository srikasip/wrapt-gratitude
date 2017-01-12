module Admin
  class SurveyPublishingsController < ApplicationController

    before_action :set_survey

    include PjaxModalController

    def new
      @survey_publishing = SurveyPublishing.new survey_id: @survey.id
    end

    def create
      @survey_publishing = SurveyPublishing.new survey_publishing_params
      @survey_publishing.survey_id = @survey
      if @survey_publishing.save
        flash.notice = "We've set #{@survey_publishing.survey.title} as the published Quiz"
        redirect_to admin_survey_path @survey
      else
        binding.pry
        render :new
      end
    end

    private def set_survey
      @survey = Survey.find params[:survey_id]
    end
    

    private def survey_publishing_params
      params.require(:survey_publishing).permit(:training_set_id)
    end
    

  end
end
