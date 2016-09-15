class GiftImagesController < ApplicationController
  before_action :set_gift

  def index
    @gift_image = @gift.gift_images.new
  end

  def create
    @gift_image = @gift.gift_images.new gift_image_params
    if @gift_image.save
      redirect_to gift_images_path(@gift)
    else
      render :index
    end
  end

  def destroy
    @gift_image = @gift.gift_images.find params[:id]
    @gift_image.destroy
    redirect_to gift_images_path(@gift)
  end

  private def set_gift
    @gift = Gift.find params[:gift_id]
  end

  private def gift_image_params
    params.require(:gift_image).permit :image
  end

end