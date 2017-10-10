class CustomerOrderMailer < ApplicationMailer
  def order_received(customer_order_id)
    @customer_order = CustomerOrder.find(customer_order_id)
    @user = @customer_order.user

    mail({
      to: @user.email,
      subject: "Order Received"
    })
  end

  def order_shipped(purchase_order_id)
    @purchase_order = PurchaseOrder.find(purchase_order_id)
    @customer_order = @purchase_order.customer_order
    @user = @customer_order.user

    mail({
      to: @user.email,
      subject: "Your Wrapt Gift is on its way!"
    })
  end

  def cannot_ship(purchase_order_id)
    @purchase_order = PurchaseOrder.find(purchase_order_id)
    @customer_order = @purchase_order.customer_order
    @user = @customer_order.user

    mail({
      to: @user.email,
      subject: "Wrapt gift options"
    })
  end
end
