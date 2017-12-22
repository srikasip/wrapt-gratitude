module Admin
  class ProfileGiftRecommendationsController < BaseController
    before_filter :load_profile, only: :edit
    
    def edit
      @new_gift_recommendation = GiftRecommendation.new(added_by_expert: true, profile: @profile)
    end

    def update_expert_notes
      @profile = Profile.preload(gift_recommendations: :gift).where(id: params[:profile_gift_recommendation_id]).first!
      if @profile.update_attributes(update_expert_notes_params)
        redirect_to edit_admin_profile_gift_recommendation_path(@profile), notice: "Expert note saved!"
      else
        @recommendations = @profile.gift_recommendations
        @new_gift_recommendation = GiftRecommendation.new(added_by_expert: true, profile: @profile)
        flash[:notice] = "Something went wrong! Your note wasn't saved."
        render :edit
      end
    end

    private

    def update_expert_notes_params
      params.require(:profile).permit(:expert_note)
    end
    
    def load_profile
      @profile = Profile.preload(gift_recommendations: :gift).where(id: params[:id]).first!
      @recommendations = @profile.gift_recommendations
    end
  end
end
