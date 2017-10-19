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

  # TODO: see what exceptions can be thrown.
  F = Class.new(StandardError)

  def estimate!
    payload_object = Tax::TransactionPayload.new(customer_order)
    payload_object.estimate = true
    self.api_request_payload = payload_object.to_hash
    self.api_response = client.create_transaction(payload_object.to_hash)
    _cache_estimation_results
  rescue F => e
    Rails.logger.fatal "[AVATAX][ESTIMATE] #{e.message}"
    self.success = false
  end

  def reconcile!
    self.api_reconcile_response = client.commit_transaction('DEFAULT', self.transaction_code, {commit: true})
    _cache_reconciliation_results
  rescue F => e
    Rails.logger.fatal "[AVATAX][RECONCILE] #{e.message}"
    self.success = false
  end

  define_method(:tax_in_cents) { self.tax_in_dollars * 100 }
  define_method(:client) { @client ||= AvaTax::Client.new(:logger => true) }

  private def _cache_estimation_results
    if api_response['error'].present?
      self.success = false
    else
      self.tax_in_dollars = api_response['lines'].sum { |x| x['taxableAmount'].to_f }
      self.transaction_code = api_response['code']
      self.success = true
    end
  end

  private def _cache_reconciliation_results
    if api_response['error'].present?
      self.success = false
    else
      self.reconciled = true
      self.success = true
    end
  end
end
