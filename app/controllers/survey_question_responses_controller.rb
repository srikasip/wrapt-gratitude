class SurveyQuestionResponsesController < ApplicationController
  before_action :set_profile
  before_action :set_survey_response

  def show
    @question_response = @survey_response.question_responses.find params[:id]
  end

  private def set_profile
    @profile = current_user.owned_profiles.find params[:profile_id]
  end

  private def set_survey_response
    @survey_response = @profile.survey_responses.find params[:survey_id]
  end
  
end
