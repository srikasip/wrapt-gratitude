module Admin
  class ProductSubcategoriesController < BaseController
    # Ajax controller for sending option tags to the gift and product forms

    def show
      @product_category = ProductCategory.find(params[:product_category_id])
      render layout: 'xhr'
    end
  end
end