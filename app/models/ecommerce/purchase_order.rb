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

  has_many :pretty_parcels, through: :gift
  has_many :shipping_parcels, through: :gift
  # Vendors can change the box before they acknowledge an order if needed.
  belongs_to :forced_shipping_parcel, class_name: 'Parcel', foreign_key: :shipping_parcel_id

  validates :order_number, presence: true
  validates :vendor_token, uniqueness: true
  validates :status, inclusion: { in: VALID_ORDER_STATUSES }
  validates :status, exclusion: { in: [PARTIALLY_CANCELLED] }

  before_validation -> { self.order_number ||= "PO-#{InternalOrderNumber.next_val_humanized}" }
  before_validation -> { self.vendor_token ||= self.vendor_id.to_s+'-'+self.order_number+'-'+SecureRandom.hex(16) }

  delegate :cart_id, :recipient_name, :ship_street1, :ship_street2, :ship_street3, :ship_city, :ship_state, :ship_zip, :ship_country, to: :customer_order
  delegate :name, to: :gift, prefix: true
  delegate :name, to: :vendor, prefix: true
  delegate :pretty_parcel, to: :gift, prefix: false
  delegate :profile, to: :customer_order, prefix: false
  delegate :shipping_choice, to: :customer_order
  delegate :tracking_url, :tracking_number, to: :shipping_label, allow_nil: true

  scope :acknowledged,    -> { where(vendor_acknowledgement_status: [FULFILL, DO_NOT_FULFILL]) }
  scope :do_not_fulfill,  -> { where(vendor_acknowledgement_status: DO_NOT_FULFILL) }
  scope :okay_to_fulfill, -> { where(vendor_acknowledgement_status: FULFILL) }
  scope :unacknowledged,  -> { where(vendor_acknowledgement_status: nil) }

  define_method(:to_service)                   { PurchaseService.new(cart_id: self.cart_id) }
  define_method(:shipping_parcel)              { forced_shipping_parcel || gift.shipping_parcel }
  define_method(:shipped_or_better?)           { self.status.in?(SHIPPED_OR_BETTER) }
  define_method(:can_change_acknowledgements?) { self.status.in? [ SUBMITTED, ORDER_INITIALIZED ] }
  define_method(:vendor_accepted?)             { self.vendor_acknowledgement_status == FULFILL }
  define_method(:vendor_rejected?)             { self.vendor_acknowledgement_status == DO_NOT_FULFILL }
  define_method(:total_due_in_dollars)         { self.total_due_in_cents.to_i / 100.0 }
  define_method(:handling_cost_in_dollars)     { self.handling_cost_in_cents.to_i / 100.0 }
  define_method(:shipping_cost_in_dollars)     { self.shipping_cost_in_cents.to_i / 100.0 }
  define_method(:fulfill?)                     { self.vendor_acknowledgement_status == 'fulfill' }

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

  def shipping_rate
    @shipping_rate ||=
      PurchaseService::ShippingService.find_rate({
        rates: self.shipment.rates,
        shipping_choice: shipping_choice,
        vendor: self.vendor
      })
  end
end
