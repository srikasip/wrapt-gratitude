class GiftsController < ApplicationController
  before_action :set_gift, only: [:show, :edit, :update, :destroy]

  def index
    @gifts = Gift.all
  end

  def show
  end

  def new
    @gift = Gift.new date_available: Date.today
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
    redirect_to gifts_url, notice: 'Gift was successfully deleted.'
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
      :calculate_cost_from_products
      )
    # result[:cost] = nil if result[:calculate_cost_from_products]
    # result
  end
end
