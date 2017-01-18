class SurveyResponseCompletionsController < ApplicationController
  include RequiresLoginOrInvitation

  before_action :set_profile
  before_action :set_survey_response

  def show
    @survey_response_completion = SurveyResponseCompletion.new profile: @profile, user: current_user
    GenerateProfileRecommendationsJob.perform_later @profile
  end

  def create
    @survey_response_completion = SurveyResponseCompletion.new profile: @profile, user: current_user
    @survey_response_completion.assign_attributes survey_response_completion_params
    if @survey_response_completion.save
      # TODO email the recipient
      # TODO mark survey completed for tracking purposes
      flash.notice = 'Gift Recommendations Coming in Release 9'
      redirect_to root_path
    else
      flash.alert = 'Oops! Looks like we need a bit more info.'
      render :show
    end
  end

  private def survey_response_completion_params
    params.require(:survey_response_completion).permit(
      :profile_email,
      :user_first_name,
      :user_last_name,
      :user_email,
      :user_password
    )
  end
  

  private def set_profile
    @profile = current_user.owned_profiles.find params[:profile_id]
  end

  private def set_survey_response
    @survey_response = @profile.survey_responses.find params[:survey_id]
  end
end
