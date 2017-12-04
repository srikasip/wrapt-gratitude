=begin
https://help.avalara.com/Frequently_Asked_Questions/001/How_do_I_drop-ship_with_Avalara%3F?origin=deflection
https://developer.avalara.com/api-reference/avatax/rest/v2/
https://taxcode.avatax.avalara.com/
=end

module Ec
  class Tax::Transaction < ApplicationRecord
    has_paper_trail(
      ignore: [:updated_at, :created_at, :id],
      meta: {
        cart_id: :cart_id
      }
    )

    belongs_to :customer_order

    validates :api_request_payload, presence: true
    validates :api_capture_response, presence: true
    validates :cart_id, presence: true
    validates :tax_in_dollars, numericality: { greater_than_or_equal_to: 0 }, if: :success?
    validates :transaction_code, presence: true, if: :success?

    define_method(:tax_in_cents) { self.tax_in_dollars * 100 }
    define_method(:client) { @client ||= AvaTax::Client.new(:logger => true) }
    define_method(:adjustable?) { self.captured? && self.reconciled? }

    # Nothing shows up in Avalara. This is just to get an approximatation
    def estimate!
      payload_object = Tax::TransactionPayload.new(customer_order)
      payload_object.estimate = true
      self.api_request_payload = payload_object.to_hash
      self.is_estimate = true
      self.api_estimation_response = client.create_transaction(payload_object.to_hash)
      _cache_estimation_results
    rescue Faraday::Error, NoMethodError, Exception => e
      Rails.logger.fatal "[AVATAX][ESTIMATE] #{e.message}"
      _email_error(e.message)
      self.success = false
      self.api_estimation_response ||= { msg: e.message }
    end

    # A real record in Avalara. It's not official until reconciled (aka commited)
    def capture!
      payload_object = Tax::TransactionPayload.new(customer_order)
      payload_object.estimate = false
      self.api_request_payload = payload_object.to_hash
      self.is_estimate = false
      self.api_capture_response = client.create_transaction(payload_object.to_hash)
      _cache_capture_results
    rescue Faraday::Error, NoMethodError, Exception => e
      Rails.logger.fatal "[AVATAX][CAPTURE] #{e.message}"
      _email_error(e.message)
      self.success = false
      self.api_capture_response ||= { msg: e.message }
    end

    def reconcile!
      self.api_reconcile_response = client.commit_transaction(Tax::COMPANY, self.transaction_code, {commit: true})
      self.reconciled = true
    rescue Faraday::Error, Exception => e
      Rails.logger.fatal "[AVATAX][RECONCILE] #{e.message}"
      _email_error(e.message)
      self.success = false
    end

    def adjust!
      payload_object = Tax::TransactionPayload.new(customer_order)
      payload_object.estimate = false
      payload_object.adjustment = true

      self.api_request_payload = payload_object.to_hash

      if payload_object.void?
        void!
      else
        begin
          self.api_adjustment_response = client.adjust_transaction(Ec::Tax::COMPANY, self.transaction_code, payload_object.to_hash)
          _cache_adjustment_results
        rescue Faraday::Error, NoMethodError, Exception => e
          Rails.logger.fatal "[AVATAX][ADJUST] #{e.message}"
          _email_error(e.message)
          self.success = false
          self.api_adjustment_response ||= { msg: e.message }
        end
      end
    end

    def void!
      payload_object = Tax::TransactionPayload.void_hash

      # https://developer.avalara.com/api-reference/avatax/rest/v2/methods/Transactions/VoidTransaction/
      self.api_adjustment_response = client.void_transaction(Ec::Tax::COMPANY, self.transaction_code, payload_object)
      _cache_adjustment_results
    rescue Faraday::Error, NoMethodError, Exception => e
      Rails.logger.fatal "[AVATAX][VOID] #{e.message}"
      _email_error(e.message)
      self.success = false
      self.api_adjustment_response ||= { msg: e.message }
    end

    private

    def _cache_estimation_results
      if api_estimation_response['error'].present?
        self.success = false
        _email_error(api_estimation_response['error'])
      else
        self.tax_in_dollars = api_estimation_response['lines'].sum { |x| x['taxCalculated'].to_f }
        self.transaction_code = api_estimation_response['code']
        self.success = true
      end
    end

    def _cache_capture_results
      if api_capture_response['error'].present?
        self.success = false
        _email_error(api_capture_response['error'])
      else
        self.tax_in_dollars = api_capture_response['lines'].sum { |x| x['taxCalculated'].to_f }
        self.transaction_code = api_capture_response['code']
        self.captured = true
        self.success = true
      end
    end

    def _cache_adjustment_results
      if api_adjustment_response['error'].present?
        self.success = false
        _email_error(api_adjustment_response['error'])
      else
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
end
