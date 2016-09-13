module IntegrationTestAuthenticator
  
  def log_in_as_admin!
    visit '/private_access_session/new'
    fill_in 'Access code', with: 'wrapataptap'
    click_button 'Get Access'
  end

end