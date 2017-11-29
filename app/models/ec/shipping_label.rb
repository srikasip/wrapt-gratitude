module Ec
  class ShippingLabel < ApplicationRecord
    TRACKING_STATUSES = [
      T_UNKNOWN   = 'UNKNOWN',   # The package has not been found via the carrier's tracking system, or it has been found but not yet scanned by the carrier.
      T_TRANSIT   = 'TRANSIT',   # The package has been scanned by the carrier and is in transit.
      T_DELIVERED = 'DELIVERED', # The package has been successfully delivered.
      T_RETURNED  = 'RETURNED',  # The package is en route to be returned to the sender, or has been returned successfully.
      T_FAILURE   = 'FAILURE',   # The carrier indicated that there has been an issue with the delivery. This can happen for various reasons and depends on the carrier. This status does not indicate a technical, but a delivery issue.
    ]

    has_paper_trail(
      ignore: [:updated_at, :created_at, :id],
      meta: {
        cart_id: :cart_id
      }
    )

    include ChargeConstants

    belongs_to :shipment
    belongs_to :purchase_order
    belongs_to :customer_order

    validates :shippo_object_id, length: { is: 32 }, presence: true
    validates :shipment_id, uniqueness: true

    validates :tracking_number, presence: true, if: :success
    validates :url, presence: true, if: :success

    delegate :cart_id, to: :shipment, prefix: false

    define_method(:shipped?)   { self.tracking_status == T_TRANSIT }
    define_method(:delivered?) { self.tracking_status == T_DELIVERED }

    def run!
      # Purchase the desired rate.
      self.api_response = Shippo::Transaction.create(
        :rate            => self.shippo_object_id,
        :label_file_type => "PDF",
        :async           => false
      )
      _cache_the_results
    rescue Shippo::Exceptions::Error, Shippo::Exceptions::ConnectionError => e
      Rails.logger.fatal "[SHIPPO] #{e.message}"

      begin
        self.save
        AdminMailer.api_error(model_class: self.class.name, model_id: self.id, message: e.message).deliver_later
      rescue Exception
      end

      self.success = false
      self.api_response = JSON.parse(e.response.body) rescue {msg: e.message}
    end

    private def _cache_the_results
      return unless self.api_response.present?

      self.success = self.api_response["status"] == SHIPPO_SUCCESS

      if self.success?
        self.url = self.api_response['label_url']
        self.tracking_number = self.api_response['tracking_number']
        self.tracking_url = self.api_response['tracking_url_provider']
      else
        self.error_messages = self.api_response['messages']
      end
    end
  end
end
