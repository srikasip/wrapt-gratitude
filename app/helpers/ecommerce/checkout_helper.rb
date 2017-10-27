module Ecommerce::CheckoutHelper

  def show_top_nav?
    action_name == 'finalize'
  end

  def show_checkout_nav?
    action_name != 'finalize'
  end
end