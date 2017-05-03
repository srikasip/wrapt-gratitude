class SurveyResponseCompletionsController < ApplicationController
  include RequiresLoginOrInvitation

  before_action :set_profile
  before_action :set_survey_response
  before_action :testing_redirect, only: :show

  def login_required?
    false
  end

  def show
    @survey_response_completion = SurveyResponseCompletion.new profile: @profile, user: current_user
  end

  def create
    @survey_response_completion = SurveyResponseCompletion.new profile: @profile, user: current_user
    @survey_response_completion.assign_attributes survey_response_completion_params
    if @survey_response_completion.save
      if authentication_from_invitation_only?
        auto_login(current_user)
      end
      @profile.touch
      @survey_response.update_attribute :completed_at, Time.now
      GenerateProfileRecommendationsJob.new.perform @profile, TrainingSet.published.first
      redirect_to profile_gift_recommendations_path(@profile)
    else
      flash.alert = 'Oops! Looks like we need a bit more info.'
      render :show
    end
  end

  private def survey_response_completion_params
    params.fetch(:survey_response_completion, {}).permit(
      :profile_email,
      :user_first_name,
      :user_last_name,
      :user_email,
      :user_password
    )
  end
 
  private
  
  def testing_redirect
    if params[:profile_id].present? && current_user.unmoderated_testing_platform?
      # go directly to pretty url for loop11 testing (do not collect $200)
      redirect_to testing_survey_complete_path
    end
  end
   
  def set_profile
    profile_id = params[:profile_id] || session[:profile_id]
    @profile = current_user.owned_profiles.find profile_id
    session[:profile_id] = @profile.id
  end

  def set_survey_response
    survey_id = params[:survey_id] || session[:survey_id]
    @survey_response = @profile.survey_responses.find survey_id
    session[:survey_id] = @survey_response.id
  end
  
end
