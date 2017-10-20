class SurveyQuestionResponsesController < ApplicationController
  include RequiresLoginOrInvitation

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
    @profile = current_user.owned_profiles.find giftee_id
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
