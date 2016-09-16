class GiftImageOrderingsController < ApplicationController

  def create
    @gift = Gift.find params[:gift_id]
    GiftImageOrdering.new(create_params.merge(gift: @gift)).save
    head :ok
  end
   
  def create_params
    params.permit(ordering: [])
  end

end