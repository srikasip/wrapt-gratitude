class VendorMailer < ApplicationMailer
  if ENV['ECOMMERCE_BCC']
    default bcc: ENV['ECOMMERCE_BCC'].split(';')
  end

  def acknowledge_order_request(purchase_order_id)
    @purchase_order = PurchaseOrder.find(purchase_order_id)
    @vendor = @purchase_order.vendor

    mail({
      to: @vendor.email,
      subject: "Order Placed"
    })
  end
end
