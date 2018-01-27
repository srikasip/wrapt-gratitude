class UserSessionsController < ApplicationController
  # Controller for login / logout

  include PjaxModalController

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new user_session_params.merge(controller: self)
    @email = @user_session.email.downcase
    if login(@email, @user_session.password, @user_session.remember)
      redirect_to default_location_for_user(current_user)
    else
      @user_session.errors.add :password, 'Sorry, that password isn\'t correct'
      render :new
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
    profiles = user.owned_profiles.active.order(updated_at: :desc)
    last_profile = profiles.first
    if last_profile.present? && last_profile.updated_at > 2.hours.ago && last_profile.current_gift_recommendation_set.present?
      giftee_gift_recommendations_path(last_profile)
    elsif profiles.any?
      my_account_giftees_path
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
