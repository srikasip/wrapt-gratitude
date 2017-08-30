class Charge < ApplicationRecord
  include ChargeConstants

  validates :idempotency_key, presence: true
  validates :token, uniqueness: true
  validates :description, presence: true
  validates :state, inclusion: { in: VALID_STATES, message: "must be in set of #{VALID_STATES.join(',')}" }

  def charged?
    self.state.in?(CHARGED_STATES)
  end

  def amount_in_dollars
    self.amount_in_cents / 100.0
  end
end
