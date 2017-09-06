class ShippingLabel < ApplicationRecord
  include ChargeConstants

  belongs_to :shipment
  belongs_to :purchase_order, through: :shipment

  validates :shippo_object_id, length: { is: 32 }

  before_save :run!, only: :create
  before_save :_cache_the_results

  def run!
    # Purchase the desired rate.
    self.api_response = Shippo::Transaction.create(
      :rate            => self.shippo_object_id,
      :label_file_type => "PDF",
      :async           => false
    )
  end

  private def _cache_the_results
    self.success = self.api_response["status"] == SHIPPO_SUCCESS

    if self.success?
      self.url = self.api_response['label_url']
      self.tracking_number = self.api_response['tracking_number']
    else
      self.error_messages = self.api_response['messages']
    end
  end
end
