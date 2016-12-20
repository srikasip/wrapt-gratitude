module SidekiqDashboardAuthentication
  
  def self.authenticated? request
    if Rails.env.development?
      return true
    else
      # TODO admin authentication
      return false
    end
  end

end