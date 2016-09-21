class ProductImagesController < ApplicationController
  before_action :set_product

  def index
    @product_image = @product.product_images.new
  end

  def create
    @product_image = @product.product_images.new product_image_params
    if @product_image.save
      redirect_to product_images_path(@product)
    else
      render :index
    end
  end

  def destroy
    @product_image = @product.product_images.find params[:id]
    @product_image.destroy
    redirect_to product_images_path(@product)
  end

  def make_primary
    @product_image = @product.product_images.find params[:id]
    @product.product_images.update_all primary: false
    @product_image.update primary: true
    redirect_to product_images_path(@product)
  end

  private def set_product
    @product = Product.find params[:product_id]
  end

  private def product_image_params
    params.require(:product_image).permit :image
  end

end