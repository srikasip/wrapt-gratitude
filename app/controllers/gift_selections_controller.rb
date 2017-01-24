class GiftSelectionsController < ApplicationController
  before_action :set_profile

  def create
    @gift_selection = @profile.gift_selections.new gift_selection_params
    @gift_selection.save!
    GiftSelectionsChannel.broadcast_to @profile, gift_selections_html: render_gift_selections, count: @profile.gift_selections.count
    head :ok
  end

  def destroy
    @gift_selection = @profile.gift_selections.find params[:id]
    @gift_selection.destroy
    GiftSelectionsChannel.broadcast_to @profile, gift_selections_html: render_gift_selections, count: @profile.gift_selections.count
    head :ok
  end

  def gift_selection_params
    params.require(:gift_selection).permit(
      :gift_id
    )
  end

  private def set_profile
    @profile = current_user.owned_profiles.find params[:profile_id]
  end

  private def render_gift_selections
    ApplicationController.renderer.render 'gift_selections/_index', locals: {profile: @profile}, layout: false
  end
  

end
