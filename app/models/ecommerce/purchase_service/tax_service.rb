class PurchaseService::TaxService
  attr_accessor :cart_id, :client, :customer_order

  delegate :api_response, :success?, :tax_in_cents, :tax_in_dollars, to: :our_transaction

  def initialize(cart_id:nil, customer_order:nil)
    if cart_id.nil? && customer_order.nil?
      raise InternalConsistencyError, "You must provide some way of getting the customer order"
    end
    self.cart_id         = cart_id
    self.customer_order  = customer_order || CustomerOrder.find_by(cart_id: self.cart_id)
    self.cart_id       ||= customer_order.cart_id
    self.client          = AvaTax::Client.new(:logger => true)
  end

  define_method(:real?)     { self.our_transaction.reconciled? }
  define_method(:estimate?) { !real? }

  def estimate!
    raise "Cannot estimate a reconciled transaction" if our_transaction.reconciled?

    _safely do
      our_transaction.estimate!
      our_transaction.save!
    end
  end

  def reconcile!
    raise "Cannot reconcile a reconciled transaction" if our_transaction.reconciled?

    _safely do
      our_transaction.reconcile!
      our_transaction.save!
    end
  end

  # If you cancel or partially cancel an order and we've reconciled already,
  # we'll need to update avalara.
  def adjust!
    raise "not implemented yet"
  end

  def our_transaction
    @our_transaction ||=
      Tax::Transaction.
        where(cart_id: self.cart_id).
        where(customer_order: self.customer_order).
        first_or_initialize
  end

  private

  def _safely
    Tax::Transaction.transaction do
      yield
    end
  end
end
