class ProgressBarViewModel

  STEPS = {
    gift_wrapt: {
      required_fields: [:gift_wrapt, :include_note],
      fields: [:gift_wrapt, :include_note, :note_content]
    },
    shipping: {
      required_fields: [:gift_wrapt, :include_note, :ship_street1, :ship_city, :ship_zip, :ship_state, :shipping_choice],
      fields: []
    },
    payment: {
      required_fields: [:gift_wrapt, :include_note, :ship_street1, :ship_city, :ship_zip, :ship_state, :shipping_choice],
      fields: []
    },
    review: {
      required_fields: [:gift_wrapt, :include_note, :ship_street1, :ship_city, :ship_zip, :ship_state, :shipping_choice],
      fields: []
    }
  }

  def initialize(customer_order, customer_purchase, current_step)
    @customer_order = customer_order
    @current_step = current_step
    @customer_purchase = customer_purchase
  end

  def steps
    load_steps()
  end

  protected

  def load_steps()
    steps = []
    STEPS.keys.each_with_index do |step, index|
      active = step_active?(step)
      disabled = step_disabled?(step)
      complete = step_complete?(step)  
      steps.push({
        step: step, 
        active: active, 
        disabled: disabled, 
        complete: complete,
        title: step.to_s.humanize.titleize
      })
    end
    steps
  end

  def step_complete?(step)
    required_fields = STEPS[step][:required_fields]
    not_complete = (required_fields.select do |field|
      @customer_order.send(field).nil?
    end.any?)
    if step == :payment
      not_complete = !@customer_order.charge.present?
    end
    if step == :review
      not_complete = true
    end
    !not_complete
  end

  def step_active?(step)
    if step == :shipping_address || step == :shipping_choices
      @current_step == :shipping
    else
      @current_step == step
    end
  end

  def step_disabled?(step)
    disabled = true
    step_index = STEPS.keys.index(step)
    if step_index > 0
      prev_step = STEPS[STEPS.keys[step_index-1]]
      required_fields = prev_step[:required_fields]
      disabled = required_fields.select do |field|
        @customer_order.send(field).nil?
      end.any?
    else
      disabled = false
    end
    if step == :review
      disabled = !@customer_order.charge.present?
    end
    disabled
  end

end
