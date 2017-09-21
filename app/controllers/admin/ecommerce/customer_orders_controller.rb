module Admin
  module Ecommerce
    class CustomerOrdersController < BaseController
      before_action { @active_top_nav_section = 'ecommerce' }

      def index
        params[:search] ||= {}
        params[:search][:status] ||= {}
        @order_search = CustomerOrderSearch.new(params)
        @orders = @order_search.results
        @vendor_choices = Vendor.all.map { |v| [v.id, v.name] }
      end

      if ENV['ALLOW_BOGUS_ORDER_CREATION']=='true'
        def create
          order = OrderFactory.create_order!
          flash[:notice] = "Created order #{order.order_number}"
          redirect_to action: :index
        end
      end

      def show
        @order = CustomerOrder.find(params[:id])
      end

      def destroy
        flash[:alert] = "Cancellation has not been implemented yet."
        redirect_back(fallback_location: url_for(action: :index))
      end
    end
  end
end
