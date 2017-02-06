class ProfilesController < ApplicationController

  include RequiresLoginOrInvitation
  helper SurveyQuestionResponsesHelper
  helper HeroBackgroundHelper

  def login_required?
    false
  end

  def new
    @profile = current_user.owned_profiles.new
    survey = Survey.published.first
    first_question = survey.sections.first.questions.first
    @question_response = SurveyQuestionResponse.new survey_question: first_question
  end

  def create
    @profile = current_user.owned_profiles.new
    if @profile.save
      @survey_response = @profile.survey_responses.create survey: Survey.published.first
      @survey_response.ordered_question_responses.first.update question_response_params.merge(answered_at: Time.now)
      redirect_to with_invitation_scope(profile_survey_question_path(@profile, @survey_response, @survey_response.ordered_question_responses.first.next_response))
    else
      render :new
    end
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
