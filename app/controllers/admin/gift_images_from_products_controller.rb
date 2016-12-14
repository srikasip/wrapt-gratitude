module Admin
  class GiftImagesFromProductsController < BaseController

    def create
      @gift = Gift.find params[:gift_id]
      @gift_image = @gift.gift_images_from_products.new gift_image_params
      if @gift_image.save
        flash[:notice] = "Your image was successfully uploaded.  It's still being processed and will be available shortly."
      else
        flash[:alert] = "Sorry, we could not add that image for some reason.  Please file a bug report."
      end
      redirect_to admin_gift_images_path(@gift, anchor: 'available_product_images')
    end

    def gift_image_params
      params.permit(:product_image_id)
    end

  end
end