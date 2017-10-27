class SurveyResponseCompletionsController < ApplicationController
  include FeatureFlagsHelper
  extend FeatureFlagsHelper
  include InvitationsHelper
  helper :invitations

  if require_invites?
    include RequiresLoginOrInvitation
  end

  before_action :set_profile
  before_action :set_survey_response
  before_action :testing_redirect, only: :show

  def login_required?
    false
  end

  def show
    @render_loading_spinner = true
    @survey_response_completion = SurveyResponseCompletion.new profile: @profile, user: current_user
  end

  def create_via_redirect
    create
  end

  def create
    user = \
      if require_invites?
        current_user
      else
        current_user || User.new(source: 'auto_create_on_quiz_taking')
      end

    @survey_response_completion = SurveyResponseCompletion.new profile: @profile, user: user
    @survey_response_completion.assign_attributes survey_response_completion_params
    if @survey_response_completion.save
      if !require_invites? || authentication_from_invitation_only?
        auto_login(user)
      end
      @profile.owner = user
      @profile.save!
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
    if params[:giftee_id].present? && current_user&.unmoderated_testing_platform?
      # go directly to pretty url for loop11 testing (do not collect $200)
      redirect_to testing_survey_complete_path
    end
  end

  def set_profile
    giftee_id = params[:giftee_id] || session[:giftee_id]

    if current_user.present?
      @profile = current_user.owned_profiles.find_by(id: giftee_id)
    end

    # If you started a quiz anonymously, this is how you find the profile. A
    # twist is that if you log instead of creating an account at the end, we
    # have an anonymous profile, yet we can't use current_user.owned_profiles
    # because it hasn't been associated yet with the user.
    @profile ||= Profile.where(owner_id: nil).find giftee_id

    session[:giftee_id] = @profile.id
  end

  def set_survey_response
    survey_id = params[:survey_id] || session[:survey_id]
    @survey_response = @profile.survey_responses.find survey_id
    session[:survey_id] = @survey_response.id
  end
end
