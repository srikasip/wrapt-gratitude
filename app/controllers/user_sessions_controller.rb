class UserSessionsController < ApplicationController
  # Controller for login / logout

  include PjaxModalController

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new user_session_params.merge(controller: self)
    if login(@user_session.email.downcase, @user_session.password, @user_session.remember)
      if params[:return_to].present?
        redirect_to params[:return_to]
      else
        redirect_back fallback_location: default_location_for_user(current_user)
      end
    else
      # make it easier for someone to recover thier password
      # TODO: do we want to restrict this feature to activated users?
      if (existing_user = User.find_by(email: @user_session.email.downcase))
        @password_reset_request = PasswordResetRequest.new(email: existing_user.email)
        @password_reset_request.save
        flash.now['notice'] = "Sorry, that password isn\'t correct. We\'ve emailed you a link to reset your password or you can try again."
        render :new
      else
        @user_session.errors.add :password, 'Sorry, that password isn\'t correct'
        render :new
      end
    end
  end

  def destroy
    logout
    redirect_to root_path
  end

  private def login_required?
    false
  end

  private def default_location_for_user user
    if user.last_viewed_profile.present?
      giftee_gift_recommendations_path(user.last_viewed_profile)
    else
      root_path
    end
  end

  private def user_session_params
    begin
      params.require(:user_session).permit(
        :email,
        :password,
        :remember
      )
    rescue ActionController::ParameterMissing
      flash.now[:alert] = 'Sorry, but there was a problem with your browser'

      # IE11 gives us the form data in multipart format, but it doesn't make it
      # into the params variable.
      email = password = ''
      begin
        request.body.rewind
        scanner = StringScanner.new(request.body.read)
        scanner.skip_until(/user_session.email."\r\n\r\n/)
        email = scanner.scan_until(/\r\n/).chomp
        #puts "VOO: #{email}"
        scanner.skip_until(/user_session.password."\r\n\r\n/)
        password = scanner.scan_until(/\r\n/).chomp
        #puts "FOO: #{password}"
      rescue Exception
        # In case this is borked, just move on with a failed login I guess
      end

      return {email: email, password: password}
    end
  end
end
