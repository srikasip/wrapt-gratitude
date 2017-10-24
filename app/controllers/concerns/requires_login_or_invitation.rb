module RequiresLoginOrInvitation
  extend ActiveSupport::Concern
  include FeatureFlagsHelper

  included do
    before_action :require_login_or_invitation
    helper_method :current_user
    helper_method :with_invitation_scope
  end

  def require_login_or_invitation
    return true if current_user

    invitation_id = params[:invitation_id] || session[:invitation_id]
    if invitation_id.present?
      user = User.find_by_activation_token invitation_id
      session[:invitation_id] = user.activation_token
    end

    if user
      @user_from_invitation = user
    else
      require_login
    end
  end

  def current_user
    super || @user_from_invitation
  end

  private def authentication_from_invitation_only?
    # this works because sorcery stores the result of its current_user
    # method in @current_user
    current_user
    @current_user.blank? && current_user
  end


end
