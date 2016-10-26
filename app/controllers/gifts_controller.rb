class GiftsController < ApplicationController
  before_action :set_gift, only: [:show, :edit, :update, :destroy]

  def index
    @gift_search = GiftSearch.new(gift_search_params)
    @gifts = Gift
      .preload(:product_category, :product_subcategory)
      .search(gift_search_params)
      .page(params[:page])
      .per(50)
  end

  def show
  end

  def new
    @gift = Gift.new date_available: Date.today, product_category: Gift.default_product_category
  end

  def edit
  end

  def create
    @gift = Gift.new(gift_params)
    if @gift.save
      redirect_to gift_products_path(@gift), notice: 'Gift was successfully created.  Now add some products.'
    else
      render :new
    end
  end

  def update
    if @gift.update(gift_params)
      redirect_to @gift, notice: 'Gift was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @gift.destroy
    redirect_to gifts_url(context_params), notice: 'Gift was successfully deleted.'
  end

  
  private def set_gift
    @gift = Gift.find(params[:id])
  end

  private def gift_params
    result = params.require(:gift).permit(:title,
      :description,
      :selling_price,
      :cost,
      :wrapt_sku,
      :date_available,
      :date_discontinued,
      :calculate_cost_from_products,
      :calculate_price_from_products,
      :product_category_id,
      :product_subcategory_id
      )
  end

  def gift_search_params
    params_base = params[:gift_search] || ActionController::Parameters.new
    params_base.permit(:keyword, :product_category_id, :product_subcategory_id)
  end
  helper_method :gift_search_params

  def context_params
    params.permit(:page).merge(gift_search: gift_search_params)
  end
  helper_method :context_params

end
