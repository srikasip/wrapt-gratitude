class Mvp1bUserSurveysController < ApplicationController
  
  def show
    @survey = Mvp1bUserSurvey.where(id: params[:id], user_id: current_user).first! 
  end
  
  def new
    @survey = Mvp1bUserSurvey.new
  end
  
  def create
    @survey = Mvp1bUserSurvey.new(user_params.merge(user: current_user))
    if @survey.save
      redirect_to @survey
    else
      render 'new'
    end
  end
  
  def user_params
      params.require(:mvp1b_user_survey).permit(
        :age,
        :gender,
        :zip,
        :response_confidence,
        :recommendation_confidence,
        :recommendation_comment,
        :would_use_again,
        :would_tell_friend,
        :would_create_wish_list,
        :would_pay,
        :pay_comment,
        :other_services,
        :mailing_address
      )
  end
end