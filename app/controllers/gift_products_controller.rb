class GiftProductsController < ApplicationController
  before_action :set_gift

  def index
    @gift_product = @gift.gift_products.new
  end

  def create
    @gift_product = @gift.gift_products.new gift_product_params
    if @gift_product.save
      redirect_to gift_products_path(@gift)
    else
      render :index
    end
  end

  def destroy
    @gift_product = @gift.gift_products.find params[:id]
    @gift_product.destroy
    redirect_to gift_products_path(@gift)
  end

  private def set_gift
    @gift = Gift.find params[:gift_id]
  end

  private def gift_product_params
    params.require(:gift_product).permit :product_id
  end

end