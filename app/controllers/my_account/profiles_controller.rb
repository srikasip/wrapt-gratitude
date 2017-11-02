class MyAccount::ProfilesController < MyAccount::BaseController
  def show
  end

  def edit
  end

  def update
    if current_user.update user_params
      flash.notice = "We've updated your profile."
      redirect_to my_account_profile_path
    else
      render :edit
    end
  end

  private def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :password,
      :wants_newsletter
    )
  end
end
