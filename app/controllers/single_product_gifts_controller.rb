class SingleProductGiftsController < ApplicationController
  include PjaxModalController

  before_action :set_product

  def new
    if @product.single_product_gift.present?
      flash[:alert] = 'Sorry that product already has a single product gift.'
      redirect_to products_path #TODO preserve page + search
    else
      @gift = @product.build_single_product_gift product_category: Gift.default_product_category
    end
  end

  def create
    @gift = Gift.new gift_attributes_from_product.merge(gift_params)
    if @gift.save
      flash[:notice] = "Successfully created a gift from #{@product.title}"
      redirect_to products_path #TODO preserve page + search
    else
      flash[:alert] = "Sorry, we could not create a single-product gift.  Please correct the errors below"
      render :new
    end
  end

  private def set_product
    @product = Product.find params[:product_id]
  end

  private def gift_params
    params.require(:gift).permit(:product_subcategory_id)
  end

  private def gift_attributes_from_product
    {
      title: @product.title,
      description: @product.description,
      product_category: Gift.default_product_category,
      date_available: Date.today,
      products: [@product],
      source_product: @product
    }
  end
  

end