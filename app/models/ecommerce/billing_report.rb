class BillingReport < Struct.new(:params)
  def paginated_results
    base_scope = _generate_results!
    base_scope.order('purchase_orders.created_at desc').preload(:vendor, :line_items => :orderable).page(params[:page])
  end

  def csv_results
    base_scope = _generate_results!
    "a,b\n1,2"
  end

  def csv_filename
    "billing.#{vendor.name.gsub(/ /, '-').downcase}.#{search_params[:date_range_start]}.to.#{search_params[:date_range_end]}.csv"
  end

  def vendor
    Vendor.find(search_params[:vendor_id])
  end

  private

  def search_params
    params[:search]
  end

  def _generate_results!
    PurchaseOrder.all.tap do |base_scope|
      if _cannot_report?
        return base_scope.where('false').page(1)
      end

      base_scope = base_scope.where(vendor_id: search_params[:vendor_id])

      base_scope = base_scope.where("purchase_orders.created_on between ? AND ?", Date.parse(search_params[:date_range_start]), Date.parse(search_params[:date_range_end]))

      if search_params[:status].present?
        base_scope = base_scope.joins(:customer_order).where({
          customer_orders: { status: search_params[:status].keys }
        })
      end
    end
  end

  def _cannot_report?
    search_params[:vendor_id].blank? ||
    search_params[:date_range_start].blank? ||
    search_params[:date_range_end].blank? ||
    !(Date.parse(search_params[:date_range_start]) rescue false) ||
    !(Date.parse(search_params[:date_range_end]) rescue false)
  end
end
