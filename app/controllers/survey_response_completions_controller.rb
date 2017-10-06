class SurveyResponseCompletionsController < ApplicationController
  include RequiresLoginOrInvitation

  before_action :set_profile
  before_action :set_survey_response
  before_action :testing_redirect, only: :show

  def login_required?
    false
  end

  def show
    @render_loading_spinner = true
    @survey_response_completion = SurveyResponseCompletion.new profile: @profile, user: current_user
    current_user.email = nil if current_user.email.include?('PLACEHOLDER')
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
      job = GenerateRecommendationsJob.new
      job.perform(@survey_response)
      redirect_to giftee_gift_recommendations_path(@profile)
    else
      flash.now['alert'] = 'Oops! Looks like we need a bit more info.'
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
    if params[:giftee_id].present? && current_user.unmoderated_testing_platform?
      # go directly to pretty url for loop11 testing (do not collect $200)
      redirect_to testing_survey_complete_path
    end
  end

  def set_profile
    giftee_id = params[:giftee_id] || session[:giftee_id]
    @profile = current_user.owned_profiles.find giftee_id
    session[:giftee_id] = @profile.id
  end

  def set_survey_response
    survey_id = params[:survey_id] || session[:survey_id]
    @survey_response = @profile.survey_responses.find survey_id
    session[:survey_id] = @survey_response.id
  end
end
