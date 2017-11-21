module Ecommerce::CheckoutHelper

  def show_top_nav?
    action_name == 'finalize'
  end

  def show_checkout_nav?
    action_name != 'finalize'
  end

  def encouragement_message(customer_order)
    wrapt_text = ['Your gift is almost on it’s way!']
    if customer_order.gift_wrapt? && customer_order.include_note?
      wrapt_text.push('Wrapped beautifully, with a handwritten card.')
    elsif customer_order.gift_wrapt?
      wrapt_text.push('Wrapped beautifully.')
    end
    wrapt_text.push('Good job, you.')
    wrapt_text.join(' ')
  end
end