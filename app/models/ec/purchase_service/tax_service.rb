module Ec
  class PurchaseService::TaxService
    attr_accessor :cart_id, :client, :customer_order

    delegate :api_response, :adjustable?, :success?, :tax_in_cents, :tax_in_dollars, to: :our_transaction

    def initialize(cart_id: nil, customer_order: nil)
      if cart_id.nil? && customer_order.nil?
        raise InternalConsistencyError, "You must provide some way of getting the customer order"
      end
      self.cart_id         = cart_id
      self.customer_order  = customer_order || CustomerOrder.find_by(cart_id: self.cart_id)
      self.cart_id       ||= customer_order.cart_id
      self.client          = AvaTax::Client.new(:logger => true)
    end

    define_method(:real?)     { !self.estimate? }
    define_method(:estimate?) { self.our_transaction.is_estimate }

    def tax_in_cents_for_purchase_order(purchase_order)
      response = self.our_transaction.api_capture_response || self.our_transaction.api_estimation_response
      lines    = Array.wrap(response['lines'])

      relevant_lines = lines.select do |line|
        line['ref2'].include?(purchase_order.order_number)
      end

      dollars = relevant_lines.sum do |line|
        line['taxCalculated'].to_f
      end

      # e.g. dollars ==  4.14
      # 4.14 * 100 = 413.99999999999994
      # (4.14 * 100).to_i = 413 (not 414)
      # (4.14 * 100).round = 414 (correct)
      (dollars * 100).round
    end

    def estimate!
      raise "Cannot estimate a reconciled transaction" if our_transaction.reconciled?

      _safely do
        our_transaction.estimate!
        our_transaction.save!
      end
    end

    def capture!
      if our_transaction.reconciled?
        raise "Cannot capture a reconciled transaction"
      end

      _safely do
        if our_transaction.captured?
          our_transaction.void!
        end
        our_transaction.capture!
debugger if !our_transaction.valid?
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
      raise "Cannot adjust unless it's a reconciled transaction" if !our_transaction.reconciled?

      _safely do
        our_transaction.adjust!
        our_transaction.save!
      end
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
end
