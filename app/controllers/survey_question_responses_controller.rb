class SurveyQuestionResponsesController < ApplicationController
  include FeatureFlagsHelper
  extend FeatureFlagsHelper
  include InvitationsHelper
  helper :invitations

  if require_invites?
    include RequiresLoginOrInvitation
  end

  before_action :set_profile
  before_action :set_survey_response

  def login_required?
    false
  end

  def show
    @question_response = @survey_response.question_responses.find params[:id]
    @survey_response = @question_response.survey_response
    @survey_questions = @survey_response.survey.questions
  end

  def update
    @question_response = @survey_response.question_responses.find params[:id]
    @question_response.run_front_end_validations = true
    if @question_response.update question_response_params
      @question_response.update_attribute :answered_at, Time.now
      @profile.touch
      if request.xhr?
        render :json => {question_response: @question_response}
      else
        if @question_response.next_response.present?
          redirect_to with_invitation_scope(giftee_survey_question_path(@profile, @survey_response, @question_response.next_response))
        else
          redirect_to with_invitation_scope(giftee_survey_completion_path(@profile, @survey_response))
        end
      end
    else
      render :show
    end
  end

  private def set_profile
    giftee_id = params[:giftee_id] || session[:giftee_id]

    if current_user.present?
      @profile = current_user.owned_profiles.find_by(id: giftee_id)
    end

    # If you started a quiz anonymously, this is how you find the profile. A
    # twist is that if you log in instead of creating an account at the end, we
    # have an anonymous profile, yet we can't use current_user.owned_profiles
    # because it hasn't been associated yet with the user.
    @profile ||= Profile.where(owner_id: nil).find giftee_id

    # Maybe you started a giftee anonymously and logged in mid-quiz. We need to
    # connect the anonymous giftee to your account. Yes, it's possible to steal
    # an anonymous giftee somebody else started, but so what?
    if current_user.present? && @profile.owner.nil?
      @profile.owner = current_user
      @profile.save!
    end

    session[:giftee_id] = @profile.id
  end

  private def set_survey_response
    survey_id = params[:survey_id] || session[:survey_id]
    @survey_response = @profile.survey_responses.find survey_id
    session[:survey_id] = @survey_response.id
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
