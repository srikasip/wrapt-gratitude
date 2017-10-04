class CustomerOrderMailer < ApplicationMailer
  def order_received(customer_order_id)
    @customer_order = CustomerOrder.find(customer_order_id)
    @user = @customer_order.user

    mail({
      to: @user.email,
      subject: "Order Received"
    })
  end
end
