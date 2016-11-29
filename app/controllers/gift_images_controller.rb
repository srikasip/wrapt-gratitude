class GiftImagesController < ApplicationController
  before_action :set_gift

  def index
    @gift_image = @gift.uploaded_gift_images.new
    @uploader = @gift_image.image
    @uploader.success_action_redirect = new_gift_image_url(@gift)
  end

  def new
    @gift_image = @gift.uploaded_gift_images.new key: params[:key]
  end

  def create
    @gift_image = @gift.uploaded_gift_images.new gift_image_params
    if @gift_image.save
      flash[:notice] = "Your image was successfully uploaded.  It's still being processed and will be available shortly."
      redirect_to gift_images_path(@gift)
    else
      render :index
    end
  end

  def destroy
    @gift_image = @gift.uploaded_gift_images.find params[:id]
    @gift_image.destroy
    redirect_to gift_images_path(@gift)
  end

  def make_primary
    @gift_image = @gift.gift_images.find params[:id]
    @gift.gift_images.update_all primary: false
    @gift_image.update primary: true
    redirect_to gift_images_path(@gift)
  end

  private def set_gift
    @gift = Gift.find params[:gift_id]
  end

  private def gift_image_params
    params.require(:gift_images_uploaded).permit :key
  end

end