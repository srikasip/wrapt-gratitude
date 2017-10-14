=begin

https://help.avalara.com/Frequently_Asked_Questions/001/How_do_I_drop-ship_with_Avalara%3F?origin=deflection
https://developer.avalara.com/api-reference/avatax/rest/v2/
https://taxcode.avatax.avalara.com/

=end

class TaxPlay
  attr_accessor :client

  def initialize
    self.client = AvaTax::Client.new(:logger => true)
  end

  def companies
    @companies ||= client.query_companies['value']
  end

  def company
    companies.find { |x| x['companyCode'] == 'DEFAULT' }
  end

  def company_id
   company['id']
  end

  def custom_tax_codes
    @custom_tax_codes ||= lient.list_tax_codes_by_company(company_id)
  end

  def run!
    transaction!
    list_transactions_and_commit!
  end

  def list_transactions_and_commit!
    transactions = client.list_transactions_by_company('DEFAULT')
  end

  def transaction!(estimate: true)
    co     = CustomerOrder.where("ship_street1 is not null and ship_street1 != ''").last
    user   = co.user
    po     = co.purchase_orders.first
    vendor = po.vendor
    gift   = po.gift

    #co.ship_street1= '210 Winslow Way E'
    #co.ship_city='Bainbridge Island'
    #co.ship_state= 'WA'
    #co.ship_zip='98110'

    # Taxable location given how I set up the texting accout nexsuses
    vendor.street1= '220 Winslow Way E'
    vendor.city='Bainbridge Island'
    vendor.state= 'WA'
    vendor.zip='98110'

    # Jewlery for everything for testing
    gift.tax_code = TaxCode.find_by(code: 'PC040206')

    # SalesOrders aren't for tax reporting. SalesInvoice can eventually be
    # reconciled and made an offical part of the tax history.
    transaction_type = estimate ? 'SalesOrder' : 'SalesInvoice'

    payload = {
      "companyCode": "DEFAULT",
      "type": transaction_type,
      "commit": 'false',
      "date": Date.today.to_s,
      "customerCode": user.id.to_s,
      "currency_code": 'USD',
      "ReferenceCode": co.order_number,
      "Email": user.email,
      "addresses": {
        "shipTo": {
          "line1": co.ship_street1,
          "city": co.ship_city,
          "region": co.ship_state,
          "country": co.ship_country,
          "postalCode": co.ship_zip
        }
      },
      "lines": [
        {
          "amount": po.shipping_cost_in_dollars,
          "taxCode": TaxCode.shipping.code,
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
          "amount": po.total_due_in_dollars,
          "taxCode": gift.tax_code.code,
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
    }

    puts payload.ai

    transaction = client.create_transaction(payload)
    puts transaction.ai
  end
end
