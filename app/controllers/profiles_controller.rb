class ProfilesController < ApplicationController

  prepend_before_action :login_via_invitation_code

  def new
    @profile = current_user.owned_profiles.new
  end

  def create
    @profile = current_user.owned_profiles.new profile_params
    if @profile.save
      # TODO go somewhere for real
      flash.notice = 'Profile created'
      redirect_to root_path
    else
      render :new
    end
  end

  private def login_via_invitation_code
    if params[:invitation_id] && !current_user
      user = User.load_from_activation_token params[:invitation_id]
      auto_login(user) if user
    end
  end

  private def profile_params
    result = {}
    if params[:commit].in? Profile::RELATIONSHIPS
      result[:relationship] = params[:commit]
    end
    result
  end

end
