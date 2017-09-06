class PurchaseOrder < ApplicationRecord
  has_many :line_items, as: :order, dependent: :destroy

  has_one :shipment, dependent: :destroy
  has_one :shipping_label, through: :shipment

  belongs_to :customer_order
  belongs_to :vendor
  belongs_to :gift

  has_one :gift_parcel, primary_key: 'gift_id', foreign_key: 'gift_id'
  has_one :parcel, through: :gift_parcel

  validates :order_number, presence: true

  before_validation -> { self.order_number ||= "PO-#{InternalOrderNumber.next_val_humanized}" }

  delegate :name, to: :vendor, prefix: true
  delegate :recipient_name, :ship_street1, :ship_street2, :ship_street3, :ship_city, :ship_state, :ship_zip, :ship_country, to: :customer_order
  delegate :tracking_url, :tracking_number, to: :shipping_label, allow_nil: true

  def shippo_parcel_hash
    return unless parcel.present?

    parcel.as_shippo_hash.tap do |result|
      result[:weight] += gift.weight_in_pounds
    end
  end

  def total_due_in_dollars
    self.total_due_in_cents / 100.0
  end
end
