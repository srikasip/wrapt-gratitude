class MyAccount::OrdersController < MyAccount::BaseController
  helper :orders
  helper :address

  def index
    @orders = Ec::UserOrderSearch.new(current_user, params).results
    if params[:search].present? && params[:search][:profile_id].present?
      @profile_id = params[:search][:profile_id]
    end
  end

  def show
    @order = current_user.customer_orders.find(params[:id])
    @customer_purchase = @order.to_service
    @charge = @order.charge || Ec::Charge.new
  end
end
