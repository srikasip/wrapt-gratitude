module Admin
  module Users
    class ProfilesController < BaseController
      def index
        @user = User.find(params[:user_id])
        @profiles = @user.owned_profiles.order(updated_at: :desc)
      end
    end
  end
end
