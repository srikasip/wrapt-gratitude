module RequiresLoginOrInvitation
  extend ActiveSupport::Concern

  included do
    before_action :require_login_or_invitation
    helper_method :current_user
    helper_method :with_invitation_scope
  end

  def require_login_or_invitation
    return true if current_user

    if params[:invitation_id]
      user = User.find_by_activation_token params[:invitation_id]
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

  def with_invitation_scope path
    if params[:invitation_id]
      "/invitations/#{params[:invitation_id]}#{path}"
    else
      path
    end
  end

  private def authentication_from_invitation_only?
    # this works because sorcery stores the result of its current_user
    # method in @current_user
    current_user
    @current_user.blank? && current_user
  end


end