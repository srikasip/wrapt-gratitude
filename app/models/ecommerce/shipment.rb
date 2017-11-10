class Shipment < ApplicationRecord
  has_paper_trail(
    ignore: [:updated_at, :created_at, :id],
    meta: {
      cart_id: :cart_id
    }
  )

  include ChargeConstants

  belongs_to :customer_order
  belongs_to :purchase_order

  has_one :shipping_label, dependent: :destroy

  validates :address_from, presence: true
  validates :address_to, presence: true
  validates :parcel, presence: true

  def too_old_for_label_creation?
    Time.now > (object_created_at + 24.hours)
  end

  def object_created_at
    Time.parse(self.api_response['object_created'])
  rescue
    self.created_at
  end

  def run!
    self.api_response = Shippo::Shipment.create(shippo_payload)
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

  def rates
    self.api_response['rates'] || []
  end

  private def _cache_the_results
    # The status field of success does not mean success. You must just see if we have any rates
    self.success = rates.present?
  end

  private def shippo_payload
    payload = {
      :address_from => self.address_from,
      :address_to   => self.address_to,
      :parcels      => self.parcel,
      :async        => false
    }

    if insurance_in_dollars.to_f > 0 && description_of_what_to_insure.present?
      payload[:extra] = {
        insurance: {
          amount: insurance_in_dollars,
          currency: 'USD',
          content: description_of_what_to_insure
        }
      }
    end

    payload
  end
end
