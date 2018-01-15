module Admin
  class GiftRecommendationSetsController < BaseController
    before_filter :load_recommendation_set
    
    def edit
      @new_gift_recommendation = GiftRecommendation.new(added_by_expert: true, recommendation_set: @recommendation_set)
    end

    def update
      if @recommendation_set.update_attributes(update_params)
        flash.notice = "Note saved"
      else
        flash.alert = "The was a problem saving your note"
      end
      redirect_to edit_admin_gift_recommendation_set_path(@recommendation_set)
    end

    private

    def update_params
      params.require(:gift_recommendation_set).permit(:expert_note)
    end
    
    def load_recommendation_set
      @recommendation_set = GiftRecommendationSet.preload(
        :profile,
        {
          recommendations: {
            gift: [:calculated_gift_field, :primary_gift_image, :product_category, :product_subcategory]}
        }
      ).find(params[:id])
      @profile = @recommendation_set.profile
      @recommendations = @recommendation_set.recommendations
      
      @shown_to_user = []
      @recommendations.each do |rec|
        if !rec.removed_by_expert? && rec.gift.available?
          if rec.added_by_expert? || @shown_to_user.size < 12
            @shown_to_user << rec
          end
        end
      end
      
    end
  end
end
