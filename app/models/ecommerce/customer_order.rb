class CustomerOrder < ApplicationRecord
  VALID_STATUSES = [
    INITIALIZED = 'initialized',
    SUBMITTED   = 'submitted',
    PROCESSING  = 'processing',
    SHIPPED     = 'shipped',
    RECEIVED    = 'received',
    CANCELLED   = 'cancelled',
    FAILED      = 'failed',
  ]

  before_validation -> { self.order_number ||= "IN-#{InternalOrderNumber.next_val_humanized}" }
  before_validation -> { self.status ||= INITIALIZED }

  validates :status, inclusion: { in: VALID_STATUSES }
  validates :order_number, presence: true
  validates :ship_address_1, presence: true
  validates :ship_city, presence: true
  validates :ship_country, presence: true
  validates :ship_postal_code, presence: true

  belongs_to :profile
  belongs_to :user

  has_one :charge
  has_many :line_items, as: :order
  has_many :shipments
  has_many :shipping_labels, through: :shipments
  has_many :purchase_orders

  delegate :email, :name, to: :user, prefix: true

  def compute_amount_in_cents
    return @amount_in_cents unless @amount_in_cents.nil?

    amount_in_cents = 0.0

    # Items
    line_items.each do |line_item|
    end

    #TODO: Shipping
    #TODO: Taxes
    #
    raise 'wip'

    amount_in_cents
  end

  private
end
