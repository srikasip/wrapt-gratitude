class InvitationsController < ApplicationController

  def show
    user = User.load_from_activation_token(params[:id])
    if user.present?
      user.update_attribute(:activation_state, 'active')
    else
      flash.alert = 'Sorry that link is not valid'
    end
    redirect_to root_path
  end

  def login_required?
    false
  end

end
