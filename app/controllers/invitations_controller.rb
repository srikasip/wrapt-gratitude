class InvitationsController < ApplicationController

  def show
    user = User.load_from_activation_token(params[:id])
    if user.present?
      user.activate!
      auto_login(user)
    else
      flash.alert = 'Sorry that link is not valid'
    end
    redirect_to root_path
  end

  def login_required?
    false
  end

end
