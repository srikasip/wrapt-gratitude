class VendorMailer < ApplicationMailer
  default from: 'Wrapt Orders <orders@wrapt.com>'

  if ENV['ECOMMERCE_BCC']
    default bcc: ENV['ECOMMERCE_BCC'].split(';')
  end

  def acknowledge_order_request(purchase_order_id)
    @purchase_order = Ec::PurchaseOrder.find(purchase_order_id)
    @vendor = @purchase_order.vendor

    mail({
      to: @vendor.email,
      subject: "Order Placed"
    })
  end
end
