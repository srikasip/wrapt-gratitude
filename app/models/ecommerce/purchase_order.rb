class PurchaseOrder < ApplicationRecord
  include ShippingComputer
  include OrderStatuses

  FULFILL = 'fulfill'
  DO_NOT_FULFILL = 'do_not_fulfill'

  NO_FULFILL_REASONS = [
    "don't have one or more products in inventory",
    "can't use the shipping carrier",
    "one or more products discontinued",
    "did not receive shipping label",
    "don't have proper boxes",
    "other"
  ]

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :line_items, as: :order, dependent: :destroy

  has_one :shipment, dependent: :destroy
  has_one :shipping_label, through: :shipment

  belongs_to :customer_order
  belongs_to :vendor
  belongs_to :gift

  #has_one :gift_parcel, primary_key: 'gift_id', foreign_key: 'gift_id'
  #has_one :parcel, through: :gift_parcel
  has_many :pretty_parcels, through: :gift
  has_many :shipping_parcels, through: :gift
  delegate :pretty_parcel, :shipping_parcel, to: :gift, prefix: false

  validates :order_number, presence: true
  validates :vendor_token, uniqueness: true
  validates :status, inclusion: { in: VALID_ORDER_STATUSES }
  validates :status, exclusion: { in: [PARTIALLY_CANCELLED] }

  before_validation -> { self.order_number ||= "PO-#{InternalOrderNumber.next_val_humanized}" }
  before_validation -> { self.vendor_token ||= self.vendor_id.to_s+'-'+self.order_number+'-'+SecureRandom.hex(16) }

  delegate :name, to: :vendor, prefix: true
  delegate :cart_id, :recipient_name, :ship_street1, :ship_street2, :ship_street3, :ship_city, :ship_state, :ship_zip, :ship_country, to: :customer_order
  delegate :tracking_url, :tracking_number, to: :shipping_label, allow_nil: true
  delegate :shipping_choice, to: :customer_order

  scope :okay_to_fulfill, -> { where(vendor_acknowledgement_status: FULFILL) }
  scope :do_not_fulfill, -> {  where(vendor_acknowledgement_status: DO_NOT_FULFILL) }
  scope :acknowledged, -> {  where(vendor_acknowledgement_status: [FULFILL, DO_NOT_FULFILL]) }
  scope :unacknowledged, -> {  where(vendor_acknowledgement_status: nil) }

  def can_change_acknowledgements?
    self.status == CustomerOrder::SUBMITTED
  end

  def vendor_accepted?
    self.vendor_acknowledgement_status == FULFILL
  end

  def vendor_rejected?
    self.vendor_acknowledgement_status == DO_NOT_FULFILL
  end

  def shippo_parcel_hash
    return unless shipping_parcel.present?

    shipping_parcel.as_shippo_hash.tap do |result|
      # Start with the parcel's weight

      # Add the gift weight
      result[:weight] += gift.weight_in_pounds

      # Add the pretty box's weight
      result[:weight] += pretty_parcel.weight_in_pounds

      # Packing material estimate
      result[:weight] += ESTIMATED_WEIGHT_IN_POUNDS_OF_PACKING_MATERIAL

      result[:weight] = result[:weight].round(2)
    end
  end

  def total_due_in_dollars
    self.total_due_in_cents / 100.0
  end

  def handling_cost_in_dollars
    self.handling_cost_in_cents / 100.0
  end

  def fulfill?
    self.vendor_acknowledgement_status == 'fulfill'
  end

  def shipping_rate
    @shipping_rate ||=
      CustomerPurchase::ShippingService.find_rate({
        rates: self.shipment.rates,
        shipping_choice: shipping_choice,
        vendor: self.vendor
      })
  end
end
