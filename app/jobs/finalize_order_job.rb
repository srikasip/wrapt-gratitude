class FinalizeOrderJob < ApplicationJob
  queue_as :default

  def perform(cart_id)
    customer_purchase_service = CustomerPurchase.new(cart_id: cart_id)

    customer_purchase_service.charge_or_cancel_or_not_ready!
  end
end
