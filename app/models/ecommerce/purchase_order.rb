class PurchaseOrder < ApplicationRecord
  include ShippingComputer

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

  has_many :line_items, as: :order, dependent: :destroy

  has_one :shipment, dependent: :destroy
  has_one :shipping_label, through: :shipment

  belongs_to :customer_order
  belongs_to :vendor
  belongs_to :gift

  has_one :gift_parcel, primary_key: 'gift_id', foreign_key: 'gift_id'
  has_one :parcel, through: :gift_parcel

  validates :order_number, presence: true
  validates :vendor_token, uniqueness: true

  before_validation -> { self.order_number ||= "PO-#{InternalOrderNumber.next_val_humanized}" }
  before_validation -> { self.vendor_token ||= self.vendor_id.to_s+'-'+self.order_number+'-'+SecureRandom.hex(16) }

  delegate :name, to: :vendor, prefix: true
  delegate :cart_id, :status, :recipient_name, :ship_street1, :ship_street2, :ship_street3, :ship_city, :ship_state, :ship_zip, :ship_country, to: :customer_order
  delegate :tracking_url, :tracking_number, to: :shipping_label, allow_nil: true

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
    return unless parcel.present?

    parcel.as_shippo_hash.tap do |result|
      result[:weight] += gift.weight_in_pounds
      result[:weight] = result[:weight].round(2)
    end
  end

  def total_due_in_dollars
    self.total_due_in_cents / 100.0
  end
end
