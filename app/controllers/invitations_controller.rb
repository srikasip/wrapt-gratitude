class InvitationsController < ApplicationController

  def show
    if user = User.load_from_activation_token(params[:id])
      redirect_to success_path(user)
    elsif current_user && current_user.last_viewed_profile.present?
      redirect_to giftee_gift_recommendations_path(current_user.last_viewed_profile)
    else
      flash.alert = 'Sorry that link is not valid'
      redirect_to root_path
    end
  end

  def login_required?
    false
  end

  private

  def success_path(user)
    if existing_profile = user.owned_profiles.first
      survey_response = existing_profile.survey_responses.first
      question_response = survey_response.last_answered_response
      if question_response.next_response
        return invitation_giftee_survey_question_path(params[:id], existing_profile, survey_response, question_response.next_response)
      else
        return invitation_giftee_survey_completion_path(params[:id], existing_profile, survey_response)
      end
    else
      return new_invitation_giftee_path(params[:id], loop11_params(user))
    end
  end

  def loop11_params(user)
    if user.unmoderated_testing_platform?
      {'l11_uid' => '36686', 'UserID' => user.id}
    else
      {}
    end
  end

end
