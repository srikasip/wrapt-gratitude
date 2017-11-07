module Ec
  class PurchaseOrderSearch < Struct.new(:params)
    def results
      search_params = params[:search]

      base_scope = PurchaseOrder.all

      if search_params[:order_number].present?
        base_scope = base_scope.where("purchase_orders.order_number ilike ?", '%'+search_params[:order_number].strip+'%')
      end

      if search_params[:created_on].present?
        base_scope = base_scope.where("purchase_orders.created_on = ?", search_params[:created_on])
      end

      if search_params[:email].present?
        base_scope = base_scope.joins(:customer_order).where({
          customer_orders: { user_id: User.select(:id).where("users.email ilike ?", '%'+search_params[:email].strip+'%') }
        })
      end

      if search_params[:status].present?
        base_scope = base_scope.where(status: search_params[:status])
      end

      base_scope.order('purchase_orders.created_at desc').preload(:customer_order, :shipping_label).page(params[:page])
    end
  end
end
