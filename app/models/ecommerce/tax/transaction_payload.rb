module Tax
  class TransactionPayload
    attr_accessor :customer_order, :estimate

    delegate :user, to: :customer_order, prefix: false
    delegate :purchase_orders, to: :customer_order, prefix: false

    def initialize(customer_order)
      self.customer_order = customer_order
      self.estimate = true
    end

    def to_hash
      # SalesOrders aren't for tax reporting. SalesInvoice can eventually be
      # reconciled and made an offical part of the tax history.
      transaction_type = self.estimate ? 'SalesOrder' : 'SalesInvoice'
      user = customer_order.user

      {
        "companyCode": "DEFAULT",
        "type": transaction_type,
        "commit": 'false',
        "date": Date.today.to_s,
        "customerCode": user.id.to_s,
        "currency_code": 'USD',
        "ReferenceCode": customer_order.order_number,
        "Email": user.email,
        "addresses": {
          "shipTo": {
            "line1": customer_order.ship_street1,
            "city": customer_order.ship_city,
            "region": customer_order.ship_state,
            "country": customer_order.ship_country,
            "postalCode": customer_order.ship_zip
          }
        },
        "lines": _lines
      }
    end

    private

    def _lines
      customer_order.line_items.flat_map do |line_item|
        po = line_item.related_line_items.first.order
        vendor = po.vendor
        gift = line_item.orderable
        [
          {
            "amount": po.shipping_cost_in_dollars,
            "taxCode": Tax::Code.shipping.code,
            "description": "shipping cost to wrapt",
            "addresses": {
              "shipFrom": {
                "line1": vendor.street1,
                "city": vendor.city,
                "region": vendor.state,
                "country": vendor.country,
                "postalCode": vendor.zip
              },
            }
          },
          {
            "amount": line_item.total_price_in_dollars,
            "taxCode": (gift.tax_code&.code || Tax::Code.default.code),
            "description": gift.title,
            "Ref1": "Vendor: #{vendor.name}",
            "Ref2": "PO #{po.order_number}",
            "addresses": {
              "shipFrom": {
                "line1": vendor.street1,
                "city": vendor.city,
                "region": vendor.state,
                "country": vendor.country,
                "postalCode": vendor.zip
              },
            }
          }
        ]
      end
    end
  end
end
