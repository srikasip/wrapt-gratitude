class FinalizeOrderJob < ApplicationJob
  queue_as :default

  def perform(cart_id)
    customer_purchase_service = CustomerPurchaseService.new(cart_id: cart_id)

    # Just because a vendor just acknowledged doesn't mean the order is ready
    # since all vendors need to acknowledge.

    if customer_purchase_service.okay_to_charge?
      Rails.logger.info "Charging cart ID #{cart_id}"
    else
      Rails.logger.info "CANNOT Charge cart ID #{cart_id}. There remains un-acknowledged vendor purchase orders"
    end

    customer_purchase_service.charge_or_cancel_or_not_ready!
  end
end
