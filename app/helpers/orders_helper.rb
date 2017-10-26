module OrdersHelper
  include OrderStatuses

  def status_to_human customer_order
    case customer_order.status
    when ORDER_INITIALIZED then "Order Pending"
    when SUBMITTED  then "Order Recieved"
    when APPROVED   then "Processing"
    when PROCESSING then "Processing"
    when SHIPPED
      words = customer_order.shipping_labels.map do |shipping_label|
        "Shipped on #{format_date(shipping_label.shipped_on)}"
      end
      words.join('<br>').html_safe
    when RECEIVED
      words = customer_order.shipping_labels.map do |shipping_label|
        "Delivered on #{format_date(shipping_label.received_on)}"
      end
      words.join('<br>').html_safe
    when CANCELLED           then "Cancelled"
    when PARTIALLY_CANCELLED then "Cancelled"
    when FAILED              then "Cancelled"
    else
      "Unknown"
    end
  end

  def shipping_choice_to_human shipping_choice
    if shipping_choice == 'fastest'
      'Fastest'
    elsif shipping_choice == 'cheapest'
      'Least Expensive'
    else
      shipping_choice&.titleize
    end
  end
end
