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
    if @gift.save
      flash[:notice] = "Successfully created a gift from #{@product.title}"
      redirect_to @gift
    else
      flash[:alert] = "Sorry, we could not create a gift for the following reasons: #{@gift.errors.full_messages.join(", ")}"
      redirect_to @product
    end
  end

end