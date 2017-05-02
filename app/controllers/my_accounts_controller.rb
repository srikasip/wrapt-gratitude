class MyAccountsController < ApplicationController
  before_action :set_user


  def show
  end

  def edit
  end

  def update
    if @user.update user_params
      flash.notice = "We've updated your profile."
      redirect_to my_account_path
    else
      render :edit
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
  

  private def set_user
    @user = current_user
  end
  
end