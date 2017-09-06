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
      end
    end
  end
end
