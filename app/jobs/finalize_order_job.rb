class FinalizeOrderJob < ApplicationJob
  queue_as :default

  def perform(cart_id)
    PurchaseService.new(cart_id: cart_id).update_from_vendor_responses!
  end
end
