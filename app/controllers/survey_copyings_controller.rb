class SurveyCopyingsController < ApplicationController
  before_filter :find_survey

  def create
    copying = SurveyCopyingJob.new
    if copying.perform @survey
      flash[:notice] = 'Survey copied successfully.'
      redirect_to copying.target_survey
    else
      flash[:alert] = 'Sorry, there was a problem copying the survey'
      redirect_to [:edit, @survey]
    end
  end

  private def find_survey
    @survey = Survey.find params[:survey_id]
  end
end