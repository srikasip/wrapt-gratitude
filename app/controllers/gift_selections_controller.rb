class GiftSelectionsController < ApplicationController
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper

  before_action :set_profile

  def create
    @gift_selection = @profile.gift_selections.new gift_selection_params
    if @gift_selection.save
      broadcast_updated_gift_selections(true)
    end
    head :ok
  end

  def destroy
    @gift_selection = @profile.gift_selections.find params[:id]
    @gift_selection.destroy
    broadcast_updated_gift_selections(true)
    head :ok
  end

  def gift_selection_params
    params.require(:gift_selection).permit(
      :gift_id
    )
  end

  private def set_profile
    @profile = current_user.owned_profiles.find params[:giftee_id]
  end

  private def broadcast_updated_gift_selections(open_gift_basket)
    GiftSelectionsChannel.broadcast_to @profile,
      gift_selections_html: render_gift_selections,
      gift_basket_count: @profile.gift_selections.count,
      updated_gift_id: @gift_selection.gift_id,
      add_button_html: render_add_button_html,
      num_gifts_words: pluralize(@profile.gift_selections.count, 'item'),
      subtotal: number_to_currency(@profile.selling_price_total),
      open: open_gift_basket
  end

  private def render_gift_selections
    ApplicationController.renderer.render 'gift_selections/_index', locals: {profile: @profile}, layout: false
  end


  private def render_add_button_html
    ApplicationController.renderer.render 'gift_recommendations/_add_to_basket_button', locals: {gift_selection: @gift_selection, profile: @profile}, layout: false
  end

end
