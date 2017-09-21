module ShippingComputer
  def shipping_in_dollars_for(orderable)
    shipping_computer(orderable, :shipping_in_cents)
  end

  def shipping_cost_in_dollars_for(orderable)
    shipping_computer(orderable, :shipping_cost_in_cents)
  end

  private

  def shipping_computer(orderable, getter)
    total_weight = line_items.sum do |li|
      li.orderable.weight_in_pounds.to_f
    end

    orderable_weight = line_items.select do |li|
      li.orderable == orderable
    end.sum do |li|
      li.orderable.weight_in_pounds.to_f
    end

    if total_weight.to_f < 0.001 || send(getter).to_f < 0.001
      return 0.0
    end

    send(getter) * (orderable_weight / total_weight) / 100.0
  end
end
