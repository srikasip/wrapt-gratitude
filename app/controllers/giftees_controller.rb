class GifteesController < ApplicationController
  include RequiresLoginOrInvitation
  include FeatureFlagsHelper
  include InvitationsHelper

  helper SurveyQuestionResponsesHelper
  helper HeroBackgroundHelper
  helper CarouselHelper
  helper FeatureFlagsHelper

  before_filter :set_survey

  skip_before_action :require_login_or_invitation, only: [:create]

  # This is for story #153216815
  # Can't verify myself, but I think you can get to some kind of cached version
  # of our homepage through the Facebook app which then means the authenticity
  # token is invalid on submitting that form.
  skip_before_action :verify_authenticity_token, only: [:create]

  def login_required?
    false
  end

  def index
    @profiles = current_user.owned_profiles.active
  end

  def new
    @profile = current_user.owned_profiles.new
    first_question = if @survey.sections.any?
      @survey.sections.first.questions.first
    else
      @survey.questions.first
    end
    @question_response = SurveyQuestionResponse.new survey_question: first_question
  end

  def create
    user = fetch_user_from_session_or_invite

    if user
      @profile = user.owned_profiles.new
      @profile.first_name = 'Unknown'
      if @profile.save
        @survey_response = @profile.survey_responses.create survey: @survey
        @survey_response.ordered_question_responses.first.update question_response_params.merge(answered_at: Time.now)
        redirect_to with_invitation_scope(giftee_survey_question_path(@profile, @survey_response, @survey_response.ordered_question_responses.first.next_response))
      else
        render :new
      end
    elsif require_invites?
      redirect_to root_path
    else
      @profile = Profile.new
      @profile.first_name = 'Unknown'
      @profile.save!
      @survey_response = @profile.survey_responses.create survey: @survey
      @survey_response.ordered_question_responses.first.update question_response_params.merge(answered_at: Time.now)

      redirect_to giftee_survey_question_path(@profile, @survey_response, @survey_response.ordered_question_responses.first.next_response)
    end
  end

  private def fetch_user_from_session_or_invite
    invitation_id = params[:invitation_id] || session[:invitation_id]
    if invitation_id.present?
      @invitation_user = User.find_by_activation_token invitation_id
      if @invitation_user.present?
        session[:invitation_id] = @invitation_user.activation_token
      end
    end

    @invitation_user || current_user
  end

  private def set_survey
    @survey = Survey.published.first
  end

  # TODO - dead method no longer used?
  private def login_via_invitation_code
    if params[:invitation_id] && !current_user
      user = User.load_from_activation_token params[:invitation_id]
      auto_login(user) if user
    end
  end

  private def question_response_params
    params.require(:survey_question_response).permit(
      :text_response,
      :range_response,
      :other_option_text,
      :survey_question_id,
      :survey_question_option_id,
      survey_question_option_ids: []
    )
  end
end
