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
    elsif webhook_params.dig('data', 'tracking_status', 'object_id').blank?
      raise "Cannot continue without a shippo object ID"
    elsif webhook_params.dig('data', 'tracking_status', 'status').blank?
      raise "Cannot continue without a status"
    elsif ShippingLabel.where(shippo_object_id: webhook_params.dig('data', 'tracking_status', 'object_id')).none?
      raise "Cannot find shipment #{webhook_params.dig('data', 'tracking_status', 'object_id')}."
    end
  end

  def _process_data!
    shipping_label = ShippingLabel.find_by(shippo_object_id: data.dig('tracking_status', 'object_id'))

    shipping_label.update_attributes({
      eta: data['eta'],
      tracking_status: data.dig('tracking_status', 'status'),
      tracking_updated_at: data.dig('tracking_status', 'status_date'),
      tracking_payload: data
    })
  end

  def data
    @data ||= webhook_params.dig('data')
  end
end
