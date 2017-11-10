class VendorMailer < ApplicationMailer
  default from: 'Wrapt Orders <orders@wrapt.com>'

  EMAIL_DELIMITER_REGEX = /\s*(,|;)\s*/

  if ENV['ECOMMERCE_BCC']
    default bcc: ENV['ECOMMERCE_BCC'].split(';')
  end

  def acknowledge_order_request(purchase_order_id)
    @purchase_order = PurchaseOrder.find(purchase_order_id)
    @vendor = @purchase_order.vendor

    mail({
      to: @vendor.email.split(EMAIL_DELIMITER_REGEX),
      subject: "Order Placed"
    })
  end
end
