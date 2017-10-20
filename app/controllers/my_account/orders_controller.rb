class MyAccount::OrdersController < MyAccount::BaseController
  helper :orders
  helper :address

  def index
    @orders = UserOrderSearch.new(current_user, params).results
  end

  def show
    @order = current_user.customer_orders.find(params[:id])
    @charge = @order.charge || Charge.new
  end
end
