=begin
https://help.avalara.com/Frequently_Asked_Questions/001/How_do_I_drop-ship_with_Avalara%3F?origin=deflection
https://developer.avalara.com/api-reference/avatax/rest/v2/
https://taxcode.avatax.avalara.com/
=end

class Tax::Transaction < ApplicationRecord
  has_paper_trail(
    ignore: [:updated_at, :created_at, :id],
    meta: {
      cart_id: :cart_id
    }
  )

  belongs_to :customer_order

  validates :api_request_payload, presence: true
  validates :api_response, presence: true
  validates :cart_id, presence: true
  validates :tax_in_dollars, numericality: { greater_than_or_equal_to: 0 }, if: :success?
  validates :transaction_code, presence: true, if: :success?

  def estimate!
    payload_object = Tax::TransactionPayload.new(customer_order)
    self.api_request_payload = payload_object.to_hash
    self.api_response = client.create_transaction(payload_object.to_hash)
    _cache_estimation_results
  rescue Faraday::Error, NoMethodError, Exception => e
    Rails.logger.fatal "[AVATAX][ESTIMATE] #{e.message}"
    _email_error(e.message)
    self.success = false
    self.api_response ||= { msg: e.message }
  end

  def reconcile!
    self.api_reconcile_response = client.commit_transaction(Tax::COMPANY, self.transaction_code, {commit: true})
    _cache_reconciliation_results
  rescue Faraday::Error, Exception => e
    Rails.logger.fatal "[AVATAX][RECONCILE] #{e.message}"
    _email_error(e.message)
    self.success = false
  end

  define_method(:tax_in_cents) { self.tax_in_dollars * 100 }
  define_method(:client) { @client ||= AvaTax::Client.new(:logger => true) }

  private def _cache_estimation_results
    if api_response['error'].present?
      self.success = false
      _email_error(api_response['error'])
    else
      self.tax_in_dollars = api_response['lines'].sum { |x| x['taxCalculated'].to_f }
      self.transaction_code = api_response['code']
      self.success = true
    end
  end

  private def _cache_reconciliation_results
    if api_reconcile_response['error'].present?
      self.success = false
      _email_error(api_response['error'])
    else
      self.reconciled = true
      self.success = true
    end
  end

  def _email_error(message)
    begin
      self.save
      AdminMailer.api_error(model_class: self.class.name, model_id: self.id, message: message).deliver_later
    rescue Exception
    end
  end
end
