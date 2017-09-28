module Admin
  module Ecommerce
    class PurchaseOrdersController < BaseController
      before_action { @active_top_nav_section = 'ecommerce' }

      def index
        params[:search] ||= {}
        params[:search][:status] ||= {}
        @order_search = PurchaseOrderSearch.new(params)
        @orders = @order_search.results
      end

      def show
        @order = PurchaseOrder.find(params[:id])
        @vendor = @order.vendor
        @shipping_label = @order.shipping_label
      end

      def resend_notification
        flash[:alert] = "Note: notification resending not yet implemented"
        redirect_back(fallback_location: admin_ecommerce_purchase_orders_path)
      end
    end
  end
end
