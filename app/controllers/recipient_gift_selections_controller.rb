class RecipientGiftSelectionsController < ApplicationController
  include AuthenticatesWithRecipientAccessToken

  layout 'xhr'

  def create
    @recipient_gift_selection = @profile.recipient_gift_selections.new recipient_gift_selection_params
    if @recipient_gift_selection.save
      broadcast_updated_gift_selections
    end
    head :ok
  end

  def destroy
    @recipient_gift_selection = @profile.recipient_gift_selections.find params[:id]
    @recipient_gift_selection.destroy
    broadcast_updated_gift_selections
    head :ok
  end

  def recipient_gift_selection_params
    params.require(:recipient_gift_selection).permit(:gift_id)
  end

  private def broadcast_updated_gift_selections
    RecipientGiftSelectionsChannel.broadcast_to @profile,
      gift_selections_html: render_gift_selections,
      gift_basket_count: @profile.recipient_gift_selections.count,
      updated_gift_id: @recipient_gift_selection.gift_id,
      add_button_html: render_add_button_html
  end
  

  private def render_gift_selections
    ApplicationController.renderer.render 'recipient_gift_selections/_index', locals: {profile: @profile}, layout: false
  end

  
  private def render_add_button_html
    ApplicationController.renderer.render 'profile_recipient_reviews/_add_to_basket_button', locals: {recipient_gift_selection: @recipient_gift_selection, profile: @profile}, layout: false
  end

end
