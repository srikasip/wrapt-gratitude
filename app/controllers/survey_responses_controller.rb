class SurveyResponsesController < ApplicationController
  include RequiresLoginOrInvitation

  before_action :set_profile

  def show
    @survey_response = @profile.survey_responses.find params[:id]
    # TODO determine most recently answered question if returning
    question_response = @survey_response.question_responses.first
    redirect_to with_invitation_scope(profile_survey_question_path(@profile, @survey_response, question_response))
  end

  private def set_profile
    @profile = current_user.owned_profiles.find params[:profile_id]
  end
  
end
