module Admin
  module ProductsIndexContextHelper
    def product_search_params
      params_base = params[:product_search] || ActionController::Parameters.new
      params_base.permit(:keyword, :product_category_id, :product_subcategory_id)
    end

    def context_params
      params.permit(:page).merge(product_search: product_search_params)
    end

  end
end