class Charge < ApplicationRecord
  has_paper_trail(
    ignore: [:updated_at, :created_at, :id],
    meta: {
      cart_id: :cart_id
    }
  )

  include ChargeConstants

  validates :idempotency_key, presence: true
  validates :token, uniqueness: true
  validates :description, presence: true
  validates :status, inclusion: { in: VALID_STATES, message: "must be in set of #{VALID_STATES.join(',')}" }

  belongs_to :customer_order

  def charged?
    self.status.in?(CHARGED_STATES)
  end

  def amount_in_dollars
    self.amount_in_cents / 100.0
  end

  def auth_success?
    self.status.in? AUTHED_OKAY_STATES
  end
end
