module Admin
  class ProductImagesController < BaseController
    before_action :set_product

    def index
      @product_image = @product.product_images.new
      @uploader = @product_image.image
      @uploader.success_action_redirect = new_admin_product_image_url(@product)
    end

    def new
      @product_image = @product.product_images.new key: params[:key]
    end

    def create
      @product_image = @product.product_images.new product_image_params
      if @product_image.save
        flash[:notice] = "Your image was successfully uploaded.  It's still being processed and will be available shortly."
        redirect_to admin_product_images_path(@product)
      else
        render :index
      end
    end

    def destroy
      @product_image = @product.product_images.find params[:id]
      @product_image.destroy
      redirect_to admin_product_images_path(@product)
    end

    def make_primary
      @product_image = @product.product_images.find params[:id]
      @product.product_images.update_all primary: false
      @product_image.update primary: true
      redirect_to admin_product_images_path(@product)
    end

    private def set_product
      @product = Product.find params[:product_id]
    end

    private def product_image_params
      params.require(:product_image).permit :key
    end

  end
end