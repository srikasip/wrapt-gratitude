class SurveyResponseCompletionsController < ApplicationController
  include PjaxModalController
  include InvitationsHelper

  helper :invitations
  helper :carousel

  before_action :set_profile
  before_action :set_survey_response

  def login_required?
    false
  end

  def show
    if @profile.recommendations_generated_at.present? && current_user.present?
      redirect_to my_account_giftees_path
      return
    elsif session['just_completed_profile_id'].to_i != @profile.id
      redirect_to my_account_giftees_path
      return
    end

    @render_loading_spinner = true

    @survey_response_completion = SurveyResponseCompletion.new profile: @profile, user: current_user
    @sign_in_return_to = create_via_redirect_giftee_survey_completion_path(@profile, @survey_response)
    job = GenerateRecommendationsJob.new
    job.perform(
      @profile.gift_recommendation_sets.build(
        engine_type: 'survey_response_engine',
        engine_params: {survey_response_id: @survey_response.id}
      )
    )

    if current_user&.present?
      redirect_to action: :create_via_redirect
    else
      load_recommendations
    end
  end

  def sign_up
    # modal content on page load show action

    # remove close button from modal
    @disable_close = true

    @render_loading_spinner = true
    @survey_response_completion = SurveyResponseCompletion.new profile: @profile, user: current_user
    @sign_in_return_to = create_via_redirect_giftee_survey_completion_path(@profile, @survey_response)
  end

  def create_via_redirect
    create
  end

  def create
    # remove close button from modal
    @disable_close = true

    # stash a copy if these params we may end up editing them
    srcp = survey_response_completion_params

    user = current_user || User.new(source: 'auto_create_on_quiz_taking')

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
      render :sign_up
    elsif @survey_response_completion.save
      auto_login(user)
      @profile.owner = user
      @profile.save!
      @survey_response.update_attribute :completed_at, Time.now
      session[:last_completed_survey_at] = Time.now
      session.delete('just_completed_profile_id')
      redirect_to giftee_gift_recommendations_path(@profile)
    else
      @sign_in_return_to = create_via_redirect_giftee_survey_completion_path(@profile, @survey_response)
      @existing_user = User.find_by(email: srcp[:user_email])
      if @existing_user
        # Make it easier for someone to recover thier password by:
        # - prementively sending them a reset and also
        PasswordResetRequest.new(email: @existing_user.email).save
        # - preparing a friendly login modal form for them to try again
        @user_session = UserSession.new(email: @existing_user.email)
        # - resetting the create account for so it's less confusing
        @survey_response_completion = SurveyResponseCompletion.new profile: @profile, user: current_user
        # - not showing the spinner since we've already compiled the recommendations
        @render_loading_spinner = false
        render :existing_user
      else
        flash.now['alert'] = 'Oops! Looks like we need a bit more info.'
        render :sign_up
      end
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

  def load_recommendations
    @gift_recommendations = @profile.
       gift_recommendations.
       where(gift_id: Gift.select(:id).can_be_sold, removed_by_expert: false).
       preload(gift: [:gift_images, :primary_gift_image, :products, :product_subcategory, :calculated_gift_field])

    @gift_recommendations = GiftRecommendation.select_for_display(@gift_recommendations)
  end

  def set_survey_response
    survey_id = params[:survey_id] || session[:survey_id]
    @survey_response = @profile.survey_responses.find survey_id
    session[:survey_id] = @survey_response.id
  end
end
