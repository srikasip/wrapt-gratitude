class CustomerOrderMailer < ApplicationMailer
  helper :email
  helper :address
  helper :application
  helper :orders

  if ENV['ECOMMERCE_BCC']
    default bcc: ENV['ECOMMERCE_BCC'].split(';')
  end
  default from: 'Wrapt Orders <orders@wrapt.com>'

  def order_received(customer_order_id)
    @customer_order = Ec::CustomerOrder.find(customer_order_id)
    @user = @customer_order.user

    @expected_delivery = Ec::PurchaseService::ShippingService.new(cart_id: @customer_order.cart_id).expected_delivery.text

    mail({
      to: @user.email,
      subject: "We've got your Wrapt order"
    })
  end

  def order_shipped(purchase_order_id)
    @purchase_order = Ec::PurchaseOrder.find(purchase_order_id)
    @customer_order = @purchase_order.customer_order
    @user = @customer_order.user

    eta_string = @purchase_order.shipping_label&.eta
    @expected_delivery = Time.parse(eta_string).strftime('%b %e, %Y') rescue nil
    @expected_delivery ||= Ec::PurchaseService::ShippingService.new(cart_id: @customer_order.cart_id).expected_delivery.text

    mail({
      to: @user.email,
      subject: "Your Wrapt Gift is on its way!"
    })
  end

  def cannot_ship(purchase_order_id)
    @purchase_order = Ec::PurchaseOrder.find(purchase_order_id)
    @customer_order = @purchase_order.customer_order
    @user           = @customer_order.user
    @profile        = @customer_order.profile

    mail({
      to: @user.email,
      subject: "Wrapt gift options"
    })
  end
end
