module Admin
  class ProfileGiftRecommendationsController < BaseController
    before_filter :load_profile
    
    def edit
      @new_gift_recommendation = GiftRecommendation.new(added_by_expert: true, profile: @profile)
    end
    
    def load_profile
      @profile = Profile.preload(gift_recommendations: :gift).where(id: params[:id]).first!
      @recommendations = @profile.gift_recommendations
    end
  end
end
