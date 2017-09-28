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

  before_save :_cache_the_results

  def run!
    self.api_response = Shippo::Shipment.create(
      :address_from => self.address_from,
      :address_to   => self.address_to,
      :parcels      => self.parcel,
      :async        => false
    )
  end

  def rates
    self.api_response['rates']
  end

  private def _cache_the_results
    # The status field of success does not mean success. You must just see if we have any rates
    self.success = rates.present?
  end
end
