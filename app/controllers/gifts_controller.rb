class GiftsController < ApplicationController
  before_action :set_gift, only: [:show, :edit, :update, :destroy]

  def index
    @gifts = Gift.all
  end

  def show
  end

  def new
    @gift = Gift.new
  end

  def edit
  end

  def create
    @gift = Gift.new(gift_params)
    if @gift.save
      redirect_to @gift, notice: 'Gift was successfully created.'
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
    redirect_to gifts_url, notice: 'Gift was successfully destroyed.'
  end

  
  private def set_gift
    @gift = Gift.find(params[:id])
  end

  private def gift_params
    params.require(:gift).permit(:name, :description, :selling_price, :cost, :wrapt_sku, :date_available, :date_discontinued)
  end
end
