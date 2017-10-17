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

      def send_vendor_notification
        VendorMailer.acknowledge_order_request(params[:id]).deliver_later
        redirect_back(fallback_location: admin_ecommerce_purchase_orders_path)
      end

      def cancel_order
        flash[:alert] = "Note that this currenly only sends the cancellation email. THE ORDER WAS NOT CANCELLED."
        CustomerOrderMailer.cannot_ship(params[:id]).deliver_later
        redirect_back(fallback_location: admin_ecommerce_purchase_orders_path)
      end

      def send_order_shipped_notification
        CustomerOrderMailer.order_shipped(params[:id]).deliver_later
        redirect_back(fallback_location: admin_ecommerce_purchase_orders_path)
      end
    end
  end
end
