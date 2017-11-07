module Ec
  class ShippoTrackingWebhook < ShippoWebhook
    def run!
      _sanity_check!
      _process_data!
    end

    private

    def _sanity_check!
      if webhook_params.blank?
        raise "Must have some data to process a webhook."
      elsif webhook_params['test'] && Rails.env.production?
        raise "Trying to use shippo in testing mode, but we're in production."
      elsif webhook_params.dig('data', 'tracking_number').blank?
        raise "Cannot continue without a tracking number"
      elsif webhook_params.dig('data', 'tracking_status', 'status').blank?
        raise "Cannot continue without a status"
      end
    end

    def _process_data!
      PurchaseService::ShippingService.update_shipping_status!(data)
    end

    def data
      @data ||= webhook_params.dig('data')
    end
  end
end
