module Admin
  class SurveyPublishingsController < ApplicationController

    before_action :set_survey

    include PjaxModalController

    def create
      @survey_publishing = SurveyPublishing.new
      @survey_publishing.survey_id = @survey
      if @survey_publishing.save
        flash.notice = "We've set '#{@survey_publishing.survey.title}' as the published Quiz"
        redirect_to admin_survey_path @survey
      else
        flash.alert = "Failed to publish Quiz '#{@survey_publishing.survey.title}'"
        redirect_to admin_survey_path @survey
      end
    end

    private def set_survey
      @survey = Survey.find params[:survey_id]
    end

  end
end
