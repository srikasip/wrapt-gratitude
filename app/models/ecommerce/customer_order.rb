class CustomerOrder < ApplicationRecord
  has_paper_trail(
    ignore: [:updated_at, :created_at, :id],
    meta: {
      cart_id: :cart_id
    }
  )

  VALID_STATUSES = [
    INITIALIZED = 'initialized',
    SUBMITTED   = 'submitted',
    PROCESSING  = 'processing',
    SHIPPED     = 'shipped',
    RECEIVED    = 'received',
    CANCELLED   = 'cancelled',
    FAILED      = 'failed',
  ]

  before_validation -> { self.order_number ||= "WRAPT-#{InternalOrderNumber.next_val_humanized}" }
  before_validation -> { self.status ||= INITIALIZED }

  validates :status, inclusion: { in: VALID_STATUSES }
  validates :order_number, presence: true
  validates :ship_street1, presence: true
  validates :ship_city, presence: true
  validates :ship_state, presence: true
  validates :ship_country, presence: true
  validates :ship_zip, presence: true

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


  def total_to_charge_in_dollars
    self.total_to_charge_in_cents / 100.0
  end

  def shipping_in_dollars
    self.shipping_in_cents / 100.0
  end

  def taxes_in_dollars
    self.taxes_in_cents / 100.0
  end

  def subtotal_in_dollars
    self.subtotal_in_cents / 100.0
  end
end
