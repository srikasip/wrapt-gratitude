class SurveyQuestionResponsesController < ApplicationController
  before_action :set_profile
  before_action :set_survey_response

  def show
    @question_response = @survey_response.question_responses.find params[:id]
  end

  def update
    @question_response = @survey_response.question_responses.find params[:id]
    if @question_response.update question_response_params
      if @question_response.next_response.present?
        redirect_to profile_survey_question_path(@profile, @survey_response, @question_response.next_response)
      else
        redirect_to profile_survey_completion_path(@profile, @survey_response)
      end
    else
      render :show
    end
  end

  private def set_profile
    @profile = current_user.owned_profiles.find params[:profile_id]
  end

  private def set_survey_response
    @survey_response = @profile.survey_responses.find params[:survey_id]
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
