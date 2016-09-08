class PrivateAccessSessionsController < ApplicationController

  skip_before_action :require_private_access_session!
  # skip_before_action :authenticate_user!
  # skip_before_action :require_admin!

  def new
    @private_access_session = PrivateAccessSession.new
  end

  def create
    @private_access_session = PrivateAccessSession.new create_params
    if @private_access_session.save
      session[:private_access_granted] = true
      redirect_to root_path
    else
      render :new
    end
  end

  def destroy
    session.delete :private_access_granted
    redirect_to new_private_access_session_path
  end

  private def create_params
    params.require(:private_access_session).permit(:access_code)
  end
  

end