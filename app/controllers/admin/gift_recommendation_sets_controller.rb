module Admin
  class GiftRecommendationSetsController < BaseController
    before_filter :load_recommendation_set
    
    def edit
      @new_gift_recommendation = GiftRecommendation.new(added_by_expert: true, recommendation_set: @recommendation_set)
    end

    def update
      if @recommendation_set.update_attributes(update_params)
        flash.notice = "Notes saved"
      else
        flash.alear = "The was a problem saving your notes"
      end
      render :edit
    end

    private

    def update_params
      params.require(:gift_recommendation_set).permit(:expert_note)
    end
    
    def load_recommendation_set
      @recommendation_set = Profile.preload(:profile, {gift_recommendations: :gift}).find(params[:id])
      @profile = @recommendation_set.profile
      @recommendations = @recommendation_set.gift_recommendations
    end
  end
end
