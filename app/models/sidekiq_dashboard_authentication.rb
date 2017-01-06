module SidekiqDashboardAuthentication
  
  def self.authenticated? request
    return false unless request.session[:user_id]
    user = User.find request.session[:user_id]
    user && user.admin?
  end

end