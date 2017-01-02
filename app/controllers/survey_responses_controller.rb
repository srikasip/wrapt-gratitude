class SurveyResponsesController < ApplicationController

  prepend_before_action :login_via_invitation_code

  def new
    @survey_response = SurveyResponse.new
  end

  def create
    @survey_respose = SurveyResponse.new survey_response_params
    @survey_response.profile = current_user.owned_profiles.new
    if @survey_response.save
      # TODO go somewhere for real
      flash.notice = 'Survey Response created'
      redirect_to root_path
    else
      render :new
    end
  end

  private def login_via_invitation_code
    if params[:invitation_id] && !current_user
      user = User.load_from_activation_token params[:invitation_id]
      auto_login(user) if user
    end
  end
  
end
