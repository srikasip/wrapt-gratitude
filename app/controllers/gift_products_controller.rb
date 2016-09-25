class GiftProductsController < ApplicationController
  before_action :set_gift

  def index
    @available_products = Product
      .where.not(id: @gift.gift_products.select(:product_id))
    if params[:q].present?
      @available_products = @available_products
        .where("LOWER(title) LIKE ?", "%#{params[:q].downcase}%")
        .or(Product.where("wrapt_sku LIKE ?", "%#{params[:q]}%"))
    end
    @available_products = @available_products
      .page(params[:page])
      .per(25)
  end

  def create
    @gift_product = @gift.gift_products.new gift_product_params
    if @gift_product.save
      redirect_to gift_products_path(@gift, context_params)
    else
      render :index
    end
  end

  def destroy
    @gift_product = @gift.gift_products.find params[:id]
    @gift_product.destroy
    redirect_to gift_products_path(@gift, context_params)
  end

  def context_params
    params.permit(:page, :q)
  end
  helper_method :context_params

  private def set_gift
    @gift = Gift.find params[:gift_id]
  end

  private def gift_product_params
    params.require(:gift_product).permit :product_id
  end

end