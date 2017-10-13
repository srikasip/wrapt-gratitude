=begin

https://help.avalara.com/Frequently_Asked_Questions/001/How_do_I_drop-ship_with_Avalara%3F?origin=deflection
https://developer.avalara.com/api-reference/avatax/rest/v2/
https://taxcode.avatax.avalara.com/

=end

class Tax::Play
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
    puts transactions.ai
  end

  def transaction!(estimate: true)
    co               = CustomerOrder.where("ship_street1 is not null and ship_street1 ! = ''").last
    payload          = TransactionPayload.new(co)
    payload.estimate = true
    transaction      = client.create_transaction(payload.to_hash)

    puts transaction.ai
  end
end
