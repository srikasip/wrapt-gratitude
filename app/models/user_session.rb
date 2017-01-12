class UserSession
  include ActiveModel::Model

  attr_accessor :email, :password, :remember, :controller

  def persisted?
    false
  end
  
end