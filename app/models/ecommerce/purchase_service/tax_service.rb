class PurchaseService::TaxService
  attr_accessor :cart_id, :customer_order

  def initialize(cart_id:, customer_order:nil)
    self.cart_id        = cart_id
    self.customer_order = customer_order || CustomerOrder.find_by(cart_id: self.cart_id)
  end

  def estimated_tax_in_cents
    0.0
  end

  def estimated_tax_in_dollars
    0.0
  end

  def submit_estimated_tax!
    :no_op
  end

  private

  def _safely
    yield
  end
end
