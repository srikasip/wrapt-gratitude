module Ec
  class BillingReport < Struct.new(:params)
    PER_PAGE = 100

    def paginated_results
      base_scope = _generate_results!
      base_scope.page(params[:page]).per(PER_PAGE)
    end

    def csv_results
      base_scope = _generate_results!
      CSV.generate do |csv|
        csv << [ 'PO Number', 'CO Number', 'Date', 'Status', 'Wrapt SKU', 'Vendor SKU', 'Description', 'Wrapt Cost', 'Handling in dollars' ]
        base_scope.each do |po|
          po.line_items.each do |line_item|
            product = line_item.orderable
            customer_order = po.customer_order
            po.line_items
            csv << [
              po.order_number,
              customer_order.order_number,
              po.created_on,
              customer_order.status,
              product.wrapt_sku,
              product.vendor_sku,
              product.description,
              product.wrapt_cost,
              po.handling_cost_in_dollars
            ]
          end
        end
      end
    end

    def csv_filename
      "billing.#{vendor.name.gsub(/ /, '-').downcase}.#{search_params[:date_range_start]}.to.#{search_params[:date_range_end]}.csv"
    end

    def vendor
      Vendor.find_by(id: search_params[:vendor_id])
    end

    def has_vendor?
      vendor.present?
    end

    private

    def search_params
      params.require(:search).permit(
        :vendor_id, :date_range_start, :date_range_end, :status
      )
    end

    def _generate_results!
      base_scope = PurchaseOrder.all

      if _cannot_report?
        return base_scope.where('false').page(1)
      end

      base_scope = base_scope.where(vendor_id: search_params[:vendor_id])

      base_scope = base_scope.where("purchase_orders.created_on between ? AND ?", Date.parse(search_params[:date_range_start]), Date.parse(search_params[:date_range_end]))

      if search_params[:status].present?
        base_scope = base_scope.where(status: search_params[:status])
      end

      base_scope = base_scope.order('purchase_orders.created_at desc').preload(:customer_order, :vendor, :line_items => :orderable)
    end

    def _cannot_report?
      search_params[:vendor_id].blank? ||
      search_params[:date_range_start].blank? ||
      search_params[:date_range_end].blank? ||
      !(Date.parse(search_params[:date_range_start]) rescue false) ||
      !(Date.parse(search_params[:date_range_end]) rescue false)
    end
  end
end
