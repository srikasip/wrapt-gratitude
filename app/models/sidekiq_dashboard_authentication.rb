module SidekiqDashboardAuthentication
  
  def self.authenticated? request
    encoded_cookie = request.cookie_jar['private_access_granted']
    return encoded_cookie && Base64.decode64(encoded_cookie) == "true"
  end

end