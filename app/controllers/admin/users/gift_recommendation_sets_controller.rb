module Admin
  module Users
    class GiftRecommendationSetsController < BaseController
      def index
        @user = User.find(params[:user_id])
        @profiles = @user.profiles.order(updated_at: :desc)
      end
    end
  end
end
