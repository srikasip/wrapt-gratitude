module AuthenticatesWithRecipientAccessToken
  
  extend ActiveSupport::Concern

  included do
    before_action :load_profile_from_access_token
  end

  def login_required?
    false
  end

  def load_profile_from_access_token
    unless @profile = Profile.find_by_recipient_access_token(profile_id_param)
      flash.alert = 'Sorry, that link is not valid.'
      redirect_to root_path
    end
  end

  private def profile_id_param
    # might be params[:id]
    params[:profile_id]
  end

end