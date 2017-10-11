module OrdersHelper
  include OrderStatuses

  def status_to_human customer_order
    case customer_order.status
    when SUBMITTED  then "Order Recieved"
    when APPROVED   then "Processing"
    when PROCESSING then "Processing"
    when SHIPPED
      words = customer_order.shipping_labels.map do |shipping_label|
        "Shipped on #{shipping_label.shipped_on}"
      end
      words.join('<br>').html_safe
    when RECEIVED
      words = customer_order.shipping_labels.map do |shipping_label|
        "Delivered on #{shipping_label.received_on}"
      end
      words.join('<br>').html_safe
    when CANCELLED           then "Cancelled"
    when PARTIALLY_CANCELLED then "Cancelled"
    when FAILED              then "Cancelled"
    else
      "Unknown"
    end
  end

  def format_address(object:, prefix:)
    get = ->(x) {
      msg = (prefix+"_"+x.to_s).to_sym

      if object.respond_to?(msg)
        object.send(msg)
      else
        nil
      end
    }

    csz = "#{get.(:city)}, #{get.(:state)} #{get.(:zip)}"

    [
      get.(:street1),
      get.(:street2),
      get.(:street3),
      csz,
      get.(:country)
    ].select(&:present?).join('<br>').html_safe
  end

end
