module ApplicationCable
  class Connection < ActionCable::Connection::Base

    def connect
      unless cookies.signed[:private_access_granted]
        reject_unauthorized_connection
      end
    end

  end
end
