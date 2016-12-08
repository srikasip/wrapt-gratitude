module Admin
  class ProductImageOrderingsController < SortableListOrderingsController

    def sortables
      product = Product.find params[:product_id]
      return product.product_images
    end

  end
end