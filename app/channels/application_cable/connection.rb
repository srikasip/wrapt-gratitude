module ApplicationCable
  class Connection < ActionCable::Connection::Base
    # TODO Authenticate
    identified_by :current_user
 
    def connect
      self.current_user = find_verified_user
    end
 
    private
      def find_verified_user
        if current_user = User.find_by(id: cookies.signed[:user_id])
          current_user
        # disabling rejection of the connection, which makes it available to
        # the public without requiring login
        # this is needed in order to make RecipientGiftSelections channel work
        # since it is used by gift recipients without accounts
        # if this becomes a problem we can have ProfileRecipientReviews#show
        # set a signed cookie for the profile access token
        # and confirm that a profile or user exists before allowing the connection
        # else
        #   reject_unauthorized_connection
        end
      end
  end
end
