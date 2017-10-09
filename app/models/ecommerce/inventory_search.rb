class InventorySearch < Struct.new(:params)
  def results
    _internal_results.page(params[:page])
  end

  def unpaginated_results
    _internal_results
  end

  private

  def _internal_results
    search_params = params[:search]

    base_scope = Product.all

    if search_params[:wrapt_sku].present?
      base_scope = base_scope.where("wrapt_sku ilike ?", '%'+search_params[:wrapt_sku].strip+'%')
    end

    if search_params[:vendor_id].present?
      base_scope = base_scope.where(vendor_id: search_params[:vendor_id])
    end

    base_scope.order('wrapt_sku')
  end
end
