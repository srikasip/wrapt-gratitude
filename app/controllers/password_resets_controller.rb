class PasswordResetsController < ApplicationController

  include PjaxModalController

  def show
    @password_reset = PasswordReset.new token: params[:id]
    not_authenticated unless @password_reset.user.present?
  end

  def update
    @password_reset = PasswordReset.new password_reset_params.merge(token: params[:id])
    not_authenticated and return unless @password_reset.user.present?
    if @password_reset.save
      giftee_id = session[:giftee_id]
      survey_id = session[:survey_id]
      auto_login(@password_reset.user)
      flash.notice = "We've reset your password and signed you in."
      if giftee_id.present?
        profile = Profile.find(giftee_id)
        if profile.owner.blank?
          profile.update_attribute(:owner_id, current_user.id)
        end

        #@survey_response_completion = SurveyResponseCompletion.new profile: profile, user: current_user
        #@survey_response_completion.save
        @survey_response = profile.survey_responses.find_by(id: survey_id) || profile.survey_responses.first
        @survey_response.update_attribute(:completed_at, Time.now) unless @survey_response.completed_at.present?

        if profile.gift_recommendations.blank?
          job = GenerateRecommendationsJob.new
          job.perform(profile, survey_response_id: @survey_response.id, append: false)
        end

        if profile.owner != current_user
          redirect_to root_path
        else
          redirect_to giftee_gift_recommendations_path(giftee_id)
        end
      else
        redirect_to root_path
      end
    else
      render :show
    end
  end

  private def login_required?
    false
  end

  private def password_reset_params
    params.require(:password_reset).permit(:password)
  end


end
