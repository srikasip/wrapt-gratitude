module Admin
  module Ecommerce
    class PurchaseOrdersController < BaseController
      before_action { @active_top_nav_section = 'ecommerce' }

      def index
        params[:search] ||= {}
        params[:search][:status] ||= {}
        @order_search = Ec::PurchaseOrderSearch.new(params)
        @orders = @order_search.results
      end

      def show
        @order = Ec::PurchaseOrder.find(params[:id])
        @vendor = @order.vendor
        @shipping_label = @order.shipping_label
      end

      def send_vendor_notification
        VendorMailer.acknowledge_order_request(params[:id]).deliver_later
        redirect_back(fallback_location: admin_ecommerce_purchase_orders_path)
      end

      def cancel_order
        flash[:alert] = "Cancelled"

        order = Ec::PurchaseOrder.find(params[:id])
        cancel_service = Ec::PurchaseService::CancelService.new(purchase_order: order)
        cancel_service.run!

        redirect_back(fallback_location: admin_ecommerce_purchase_orders_path)
      end

      def send_order_shipped_notification
        CustomerOrderMailer.order_shipped(params[:id]).deliver_later
        redirect_back(fallback_location: admin_ecommerce_purchase_orders_path)
      end
    end
  end
end
