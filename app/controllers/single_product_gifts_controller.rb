class SingleProductGiftsController < ApplicationController

  def create
    @product = Product.find params[:product_id]
    @gift = Gift.new \
      title: @product.title,
      description: @product.description,
      product_category_id: @product.product_category_id,
      product_subcategory_id: @product.product_subcategory_id,
      date_available: Date.today,
      products: [@product]
    #TODO handle gift not saving (say because of missing categories)
    @gift.save!
    flash[:notice] = "Successfully created a gift from #{@product.title}"
    redirect_to @gift
  end

end