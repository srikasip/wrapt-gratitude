module Ec
  module Tax
    class TransactionPayload
      VOID_DOC = { "code": "DocVoided" }

      attr_accessor :customer_order
      attr_accessor :estimate
      attr_accessor :adjustment

      attr_reader :user

      delegate :user, to: :customer_order, prefix: false
      delegate :purchase_orders, to: :customer_order, prefix: false

      def initialize(customer_order)
        self.customer_order = customer_order
        self.estimate = true
        self.adjustment = false

        @user = customer_order.user
      end

      def void?
        _lines.blank?
      end

      def transaction_type
        # SalesOrders aren't for tax reporting. SalesInvoice can eventually be
        # reconciled and made an offical part of the tax history.
        @transaction_type ||= self.estimate ? 'SalesOrder' : 'SalesInvoice'
      end

      def self.void_hash
        VOID_DOC
      end

      def to_hash
        if void?
          VOID_DOC
        elsif self.adjustment
          # https://developer.avalara.com/api-reference/avatax/rest/v2/models/AdjustTransactionModel/
          {
            # https://developer.avalara.com/api-reference/avatax/rest/v2/models/enums/AdjustmentReason/
            #"adjustmentReason": "SourcingIssue",
            "adjustmentReason": "Other",
            "adjustmentDescription": "Order cancelled by customer or vendor unable to fulfill",
            "newTransaction": _inner_payload
          }
        else
          _inner_payload
        end
      end

      private

      def _inner_payload
        {
          "companyCode": COMPANY,
          "type": self.transaction_type,
          "commit": self.adjustment, # Adjustments are the only ones that auto-commit
          "date": Date.today.to_s,
          "customerCode": user.id.to_s,
          "currency_code": 'USD',
          "ReferenceCode": customer_order.order_number,
          "Email": self.user.email,
          "lines": _lines
        }
      end

      def _lines
        @_lines ||= \
          customer_order.non_cancelled_line_items.flat_map do |line_item|
            po = line_item.related_order
            vendor = po.vendor
            gift = line_item.orderable
            [
              {
                "amount": po.shipping_cost_in_dollars,
                "taxCode": Tax::Code.shipping.code,
                "description": "Shipping cost to wrapt",
                "Ref1": "Vendor: #{vendor.name}",
                "Ref2": "#{po.order_number}",
                "addresses": {
                  "shipFrom": {
                    "line1": vendor.street1,
                    "city": vendor.city,
                    "region": vendor.state,
                    "country": vendor.country,
                    "postalCode": vendor.zip
                  },
                  "shipTo": {
                    "line1": customer_order.ship_street1,
                    "city": customer_order.ship_city,
                    "region": customer_order.ship_state,
                    "country": customer_order.ship_country,
                    "postalCode": customer_order.ship_zip
                  }
                }
              },
              {
                "amount": line_item.taxable_total_price_in_dollars,
                "taxCode": (gift.tax_code&.code || Tax::Code.default.code),
                "description": gift.title,
                "Ref1": "Vendor: #{vendor.name}",
                "Ref2": "#{po.order_number}",
                "addresses": {
                  "shipFrom": {
                    "line1": vendor.street1,
                    "city": vendor.city,
                    "region": vendor.state,
                    "country": vendor.country,
                    "postalCode": vendor.zip
                  },
                  "shipTo": {
                    "line1": customer_order.ship_street1,
                    "city": customer_order.ship_city,
                    "region": customer_order.ship_state,
                    "country": customer_order.ship_country,
                    "postalCode": customer_order.ship_zip
                  }
                }
              }
            ]
        end
      end
    end
  end
end
