class Shipment < ApplicationRecord
  include ChargeConstants

  belongs_to :order

  validates :address_from, presence: true
  validates :address_to, presence: true
  validates :parcel, presence: true

  before_save :run!, only: :create
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
    puts "snapple"
    self.success = self.api_response['status'] == SHIPPO_SUCCESS
  end
end
