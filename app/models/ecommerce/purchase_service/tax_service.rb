class PurchaseService::TaxService
  attr_accessor :cart_id, :client, :customer_order, :tax_in_cents, :tax_in_dollars

  def initialize(cart_id:nil, customer_order:nil)
    if cart_id.nil? && customer_order.nil?
      raise InternalConsistencyError, "You must provide some way of getting the customer order"
    end
    self.cart_id        = cart_id
    self.customer_order = customer_order || CustomerOrder.find_by(cart_id: self.cart_id)
    self.client = AvaTax::Client.new(:logger => true)
  end

  define_method(:estimate?) { @estimate }
  define_method(:real?)     { !estimate?  }

  def estimate!
    @estimate = true
    payload = Tax::TransactionPayload.new(customer_order)
    payload.estimate = true
    transaction = self.client.create_transaction(payload.to_hash)
    self.tax_in_dollars = transaction.lines.sum { |x| x.taxableAmount }
    self.tax_in_cents = self.tax_in_dollars * 100
  end

  def reconcile!
    @estimate = false
    raise 'WIP'
    :no_op
  end

  private

  def _safely
    yield
  end
end
