class ProductImageOrderingsController < ApplicationController

  def create
    @product = Product.find params[:product_id]
    ProductImageOrdering.new(create_params.merge(product: @product)).save
    head :ok
  end
   
  def create_params
    params.permit(ordering: [])
  end

end