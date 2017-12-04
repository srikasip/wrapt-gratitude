module Ec
  class PurchaseService::CancelService
    include OrderStatuses

    attr_accessor :purchase_order, :customer_order, :shipping_label, :charging_service, :tax_service

    def initialize(purchase_order:)
      self.purchase_order   = purchase_order
      self.customer_order   = purchase_order.customer_order
      self.shipping_label   = purchase_order&.shipping_label || ShippingLabel.new
      self.charging_service = PurchaseService::ChargingService.new(cart_id: self.customer_order.cart_id)
      self.tax_service      = PurchaseService::TaxService.new(cart_id: self.customer_order.cart_id)
    end

    def self.run_for_customer_order!(customer_order)
      customer_order.purchase_orders.each do |purchase_order|
        cancel_service = new(purchase_order: purchase_order)
        cancel_service.run!
      end
    end

    # This is idempotent (or at least was originally designed to be)
    def run!
      shipping_label.refund!
      _refund_credit_card!
      _update_statuses!
      _adjust_tax_record!
      CustomerOrderMailer.cannot_ship(purchase_order.id).deliver_later
      VendorMailer.order_cancelled(purchase_order.id).deliver_later
    end

    private

    def _refund_credit_card!
      return if self.customer_order.charge.blank?                  # Not even far enough to have a record
      return if self.purchase_order.amount_to_refund_in_cents < 1  # Can't refund nothing
      return unless self.customer_order.charge.charged?            # Can't refund if we haven't successfully charged.

      if self.purchase_order.not_customer_refunded?
        extra_metadata = {
          purchase_order: purchase_order.order_number
        }

        Ec::Charge.transaction do
          amount_in_cents = self.purchase_order.amount_to_refund_in_cents

          charging_service.refund!(amount_in_cents, extra_metadata: extra_metadata)
          if charging_service.refund_suceeded
            self.purchase_order.update_attribute(:customer_refunded_at, Time.now)
          end
        end
      end
    end

    def _adjust_tax_record!
      if self.tax_service.adjustable?
        self.tax_service.adjust!
      end
    end

    def  _update_statuses!
      self.purchase_order.update_attribute(:status, CANCELLED)

      if self.customer_order.purchase_orders.all?(&:cancelled?)
        self.customer_order.update_attribute(:status, CANCELLED)
      else
        self.customer_order.update_attribute(:status, PARTIALLY_CANCELLED)
      end
    end
  end
end
