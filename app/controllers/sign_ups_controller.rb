class SignUpsController < ApplicationController

  def show
    invalid_link! unless @user = User.load_from_activation_token(params[:id])
  end

  def update
    unless @user = User.load_from_activation_token(params[:id])
      invalid_link!
      return
    end

    if @user.update user_params
      @user.activate!
      auto_login(@user)
      UserActivationsMailer.activation_success_email(@user).deliver_later
      flash.notice = "Thanks for signing up!"
      redirect_to root_path
    else
      render :show
    end
  end

  private def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :password   
    )
  end
  
  private def invalid_link!
    flash.alert = 'Sorry, that link is not valid.'
    redirect_to root_path
  end
  

  private def login_required?
    false
  end


  
end