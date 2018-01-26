class ProfileNotifications
  attr_reader :user
  
  def initialize(user)
    @user = user
  end
  
  def profiles
    @profiles || load_profiles
  end
  
  def load_profiles
    @profiles = user.owned_profiles.active.with_notifications
  end
  
  def count
    profiles.count
  end

end