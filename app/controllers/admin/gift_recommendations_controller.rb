module Admin
  class GiftRecommendationsController < BaseController
    before_filter :load_gift_recommendation, only: :update
    
    def create
      attrs = params.require(:gift_recommendation).permit(:profile_id, :gift_id, :expert_score)
      
      @profile = Profile.find(attrs[:profile_id])
      
      # very hackish
      wrapt_sku = attrs[:gift_id].to_s.strip
      @gift = Gift.where(wrapt_sku: wrapt_sku).first
      
      if @gift.blank?
        redirect_to edit_admin_profile_gift_recommendation_path(@profile), alert: "SKU (#{wrapt_sku}) not found"
        return
      end
      
      attrs[:gift_id] = @gift.id
      attrs[:added_by_expert] = true
      
      GiftRecommendation.transaction do
        @gift_recommendation = GiftRecommendation.create(attrs)
        @profile.expert = current_user
        @profile.save
      end
      redirect_to edit_admin_profile_gift_recommendation_path(@profile), notice: "#{@gift.title} (#{@gift.wrapt_sku}) added"
    end
    
    def update
      # can only score expert recs
      allow_params = [:removed_by_expert]
      allow_params << :expert_score if @gift_recommendation.added_by_expert?
      attrs = params.require(:gift_recommendation).permit(allow_params)
      GiftRecommendation.transaction do
        @gift_recommendation.update_attributes(attrs)
        @profile.expert = current_user
        @profile.save
      end
      redirect_to edit_admin_profile_gift_recommendation_path(@profile), notice: "#{@gift.title} (#{@gift.wrapt_sku}) updated"
    end
    
    def load_gift_recommendation
      @gift_recommendation = GiftRecommendation.preload(:profile, :gift).where(id: params[:id]).first!
      @gift = @gift_recommendation.gift
      @profile = @gift_recommendation.profile
    end
  end
end
