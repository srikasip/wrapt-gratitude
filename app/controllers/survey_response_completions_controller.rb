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
    if session['just_completed_profile_id'].to_i == @profile.id
      @render_loading_spinner = true
      @survey_response_completion = SurveyResponseCompletion.new profile: @profile, user: current_user
      @sign_in_return_to = create_via_redirect_giftee_survey_completion_path(@profile, @survey_response)
    else
      # It was a user probably using a back button or a bookmark. Don't allow that
      redirect_to my_account_giftees_path
    end
  end

  def create_via_redirect
    create
  end

  def create
    if session['just_completed_profile_id'].to_i != @profile.id
      session.delete('just_completed_profile_id')
      redirect_to my_account_giftees_path
      return
    end

    # stash a copy if these params we may end up editing them
    srcp = survey_response_completion_params

    user = \
      if require_invites?
        current_user
      else
        current_user || User.new(source: 'auto_create_on_quiz_taking')
      end

    # check for an existing user who is forgetting that they are already logged in
    if (existing_user = login(srcp[:user_email], srcp[:user_password]))
      # use their existing info on file
      # leaving the name alone
      user = existing_user
      srcp[:user_first_name] = user.first_name
      srcp[:user_last_name] = user.last_name
      # flash['alert'] = 'You have been signed in to your existing account and .'
    end

    @survey_response_completion = SurveyResponseCompletion.new profile: @profile, user: user
    @survey_response_completion.assign_attributes srcp
    if params.dig(:survey_response_completion, :user_terms_of_service_accepted) == '0'
      @survey_response_completion.add_terms_of_service_error!
      flash.now['alert'] = 'Oops! You forgot to accept our terms of service.'
      @sign_in_return_to = create_via_redirect_giftee_survey_completion_path(@profile, @survey_response)
      render :show
    elsif @survey_response_completion.save
      if !require_invites? || authentication_from_invitation_only?
        auto_login(user)
      end
      @profile.owner = user
      @profile.save!
      @survey_response.update_attribute :completed_at, Time.now
      job = GenerateRecommendationsJob.new
      job.perform(@survey_response)
      session[:last_completed_survey_at] = Time.now
      session.delete('just_completed_profile_id')
      redirect_to giftee_gift_recommendations_path(@profile)
    else
      if User.where(email: user.email).any?
        flash.now['alert'] = %[Oops! Looks like that account already exists. Try #{view_context.link_to 'signing in', new_user_session_path}.]
      else
        flash.now['alert'] = 'Oops! Looks like we need a bit more info.'
      end
      @sign_in_return_to = create_via_redirect_giftee_survey_completion_path(@profile, @survey_response)
      render :show
    end
  end

  private def survey_response_completion_params
    params.fetch(:survey_response_completion, {}).permit(
      :profile_email,
      :user_first_name,
      :user_last_name,
      :user_email,
      :user_password,
      :user_wants_newsletter,
      :user_terms_of_service_accepted
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
    @profile ||= Profile.where(owner_id: nil).find_by(id: giftee_id)

    if @profile.present?
      session[:giftee_id] = @profile.id
    else
      flash[:alert] = 'Giftee not found'
      redirect_to :root
    end
  end

  def set_survey_response
    survey_id = params[:survey_id] || session[:survey_id]
    @survey_response = @profile.survey_responses.find survey_id
    session[:survey_id] = @survey_response.id
  end
end
