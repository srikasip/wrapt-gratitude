class ProfilesController < ApplicationController
  include RequiresLoginOrInvitation
  include FeatureFlagsHelper

  helper SurveyQuestionResponsesHelper
  helper HeroBackgroundHelper
  helper CarouselHelper
  helper FeatureFlagsHelper

  before_filter :set_survey

  skip_before_action :require_login_or_invitation, only: [:create_with_auto_user_create]

  def login_required?
    require_invites? || (action_name != 'create_with_auto_user_create')
  end

  def index
    @profiles = current_user.owned_profiles
  end

  def create_with_auto_user_create
    if current_user
      # Already have a user.
      create
    elsif require_invites?
      redirect_to root_path
    else
      user = User.new(email: SecureRandom.hex(16)+"@PLACEHOLDER.com")
      user.source = 'auto_create_on_quiz_taking'
      password = SecureRandom.hex(16)
      user.password = password
      user.save!

      auto_login(user)

      create
    end
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
    @profile = current_user.owned_profiles.new
    @profile.name = 'Unknown'
    if @profile.save
      @survey_response = @profile.survey_responses.create survey: @survey
      @survey_response.ordered_question_responses.first.update question_response_params.merge(answered_at: Time.now)
      redirect_to with_invitation_scope(profile_survey_question_path(@profile, @survey_response, @survey_response.ordered_question_responses.first.next_response))
    else
      render :new
    end
  end

  private def set_survey
    if current_user&.admin? && params[:survey_id]
      @survey = Survey.where(id: params[:survey_id], test_mode: true).first
    end
    @survey ||= Survey.published.first
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
