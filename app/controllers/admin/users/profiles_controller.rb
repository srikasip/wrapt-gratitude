module Admin
  module Users
    class ProfilesController < BaseController
      def index
        @user = User.find(params[:user_id])
        @profiles = @user.owned_profiles.unarchived.order(updated_at: :desc)
        @active_profiles = @user.owned_profiles.unarchived.active.order(updated_at: :desc)
        @inactive_profiles = @profiles - @active_profiles
        @profiles = @active_profiles + @inactive_profiles
      end
    end
  end
end
