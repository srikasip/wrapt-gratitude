class VendorMailer < ApplicationMailer
  def acknowledge_order_request(purchase_order_id)
    @purchase_order = PurchaseOrder.find(purchase_order_id)
    @vendor = @purchase_order.vendor

    mail({
      to: @vendor.email,
      subject: "Order Placed"
    })
  end
end
