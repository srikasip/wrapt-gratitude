class InvitationsController < ApplicationController


  def show
    if user = User.load_from_activation_token(params[:id])
      auto_login(user)
      redirect_to success_path(user)
    else
      flash.alert = 'Sorry that link is not valid'
      redirect_to root_path
    end
  end

  def login_required?
    false
  end

  private def success_path(user)
    if existing_profile = user.owned_profiles.first
      survey_response = existing_profile.survey_responses.first
      question_response = survey_response.last_answered_response
      if question_response.next_response
        return profile_survey_question_path(existing_profile, survey_response, question_response.next_response)  
      else
        # TODO send to gift selection screen
        return profile_survey_question_path(existing_profile, survey_response, question_response)
      end
      
    else
      return new_profile_path
    end
  end
  

end