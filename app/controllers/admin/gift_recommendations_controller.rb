module Admin
  class GiftRecommendationsController < BaseController
    before_filter :load_gift_recommendation, only: :update
    before_filter :load_gift_recommendation_set, only: :create
    
    def create
      attrs = params.require(:gift_recommendation).permit(:gift_id)
      
      @profile = @recommendation_set.profile
      
      # very hackish
      wrapt_sku = attrs[:gift_id].to_s.strip
      @gift = Gift.where(wrapt_sku: wrapt_sku).first
      
      if @gift.blank?
        redirect_to edit_path, alert: "SKU (#{wrapt_sku}) not found"
        return
      end
      
      attrs[:gift_id] = @gift.id
      attrs[:added_by_expert] = true
      attrs[:position] = -1
      
      GiftRecommendation.transaction do
        @gift_recommendation = @recommendation_set.recommendations.create(attrs)
        @recommendation_set.update_attributes(expert: current_user, updated_at: Time.now)
<<<<<<< HEAD
=======
        @recommendation_set.normalize_recommendation_positions!
>>>>>>> master
      end
      redirect_to edit_path, notice: "#{@gift.title} (#{@gift.wrapt_sku}) added"
    end
    
    def update
      # can only score expert recs
      attrs = params.require(:gift_recommendation).permit(:removed_by_expert)
      GiftRecommendation.transaction do
        @gift_recommendation.update_attributes(attrs)
        @recommendation_set.update_attributes(expert: current_user, updated_at: Time.now)
      end
      redirect_to edit_path, notice: "#{@gift.title} (#{@gift.wrapt_sku}) updated"
    end
    
    def edit_path
      edit_admin_gift_recommendation_set_path(@recommendation_set)
    end
    
    def load_gift_recommendation
      @gift_recommendation = GiftRecommendation.preload({recommendation_set: :profile}, :gift).find(params[:id])
      @gift = @gift_recommendation.gift
      @recommendation_set = @gift_recommendation.recommendation_set
      @profile = @recommendation_set.profile
    end
    
    def load_gift_recommendation_set
      @recommendation_set = GiftRecommendationSet.find(params[:gift_recommendation_set_id])
      @profile = @recommendation_set.profile
    end
  end
end
