class MyAccount::OrdersController < MyAccount::BaseController
  helper :orders

  def index
    @orders = UserOrderSearch.new(current_user, params).results
  end

  def show
  end
end
