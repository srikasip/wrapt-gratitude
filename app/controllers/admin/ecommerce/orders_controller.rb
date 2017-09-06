module Admin
  module Ecommerce
    class OrdersController < BaseController
      before_action { @active_top_nav_section = 'ecommerce' }

      def index
        params[:search] ||= {}
        params[:search][:status] ||= {}
        @order_search = OrderSearch.new(params)
        @orders = @order_search.results
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
        # cancel an order if it hasn't been shipped.
        raise "wip"
      end

      class OrderSearch < Struct.new(:params)
        def results
          search_params = params[:search]

          base_scope = CustomerOrder.all

          if search_params[:order_number].present?
            base_scope = base_scope.where("order_number ilike ?", '%'+search_params[:order_number]+'%')
          end

          if search_params[:created_on].present?
            base_scope = base_scope.where("created_on = ?", search_params[:created_on])
          end

          if search_params[:email].present?
            base_scope = base_scope.where({
              user_id: User.select(:id).where("users.email ilike ?", '%'+search_params[:email]+'%')
            })
          end

          if search_params[:status].present?
            base_scope = base_scope.where(status: search_params[:status].keys)
          end

          base_scope.order('created_at desc').page(params[:page])
        end
      end
    end
  end
end
