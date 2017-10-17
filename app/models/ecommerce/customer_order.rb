class CustomerOrder < ApplicationRecord
  include ShippingComputer
  include OrderStatuses

  has_paper_trail(
    ignore: [:updated_at, :created_at, :id],
    meta: {
      cart_id: :cart_id
    }
  )

  before_validation -> { self.order_number ||= "WRAPT-#{InternalOrderNumber.next_val_humanized}" }
  before_validation -> { self.status ||= INITIALIZED }

  validates :status, inclusion: { in: VALID_ORDER_STATUSES }
  validates :order_number, presence: true
  validates :ship_zip, length: { minimum: 5 }, allow_blank: true

  belongs_to :profile
  belongs_to :user

  has_one :charge, dependent: :destroy
  has_many :line_items, as: :order, dependent: :destroy

  has_many :gifts, through: :line_items, source_type: "Gift", source: :orderable

  has_many :shipments
  has_many :shipping_labels
  has_many :purchase_orders, dependent: :destroy

  delegate :email, :name, to: :user, prefix: true
  delegate :name, to: :profile, prefix: true

  define_method(:shipping_in_dollars)        { self.shipping_in_cents / 100.0 } # Amount charged to customer
  define_method(:shipping_cost_in_dollars)   { self.shipping_cost_in_cents / 100.0 } # Wrapt's cost
  define_method(:total_to_charge_in_dollars) { self.total_to_charge_in_cents / 100.0 }
  define_method(:shipping_in_dollars)        { self.shipping_in_cents / 100.0 }
  define_method(:taxes_in_dollars)           { self.taxes_in_cents / 100.0 }
  define_method(:subtotal_in_dollars)        { self.subtotal_in_cents / 100.0 }
end