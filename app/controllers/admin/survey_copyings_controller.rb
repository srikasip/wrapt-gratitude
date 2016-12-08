module Admin
  class SurveyCopyingsController < BaseController
    before_filter :find_survey

    def create
      target_survey = Survey.new title: "Copy of #{@survey.title}", copy_in_progress: true
      target_survey.save!
      SurveyCopyingJob.perform_later @survey, target_survey
      flash[:notice] = "We've begun copying that quiz.  It will be ready shortly."
      redirect_to surveys_path
    end

    private def find_survey
      @survey = Survey.find params[:survey_id]
    end
  end
end