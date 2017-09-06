class Charge < ApplicationRecord
  include ChargeConstants

  validates :idempotency_key, presence: true
  validates :token, uniqueness: true
  validates :description, presence: true
  validates :state, inclusion: { in: VALID_STATES, message: "must be in set of #{VALID_STATES.join(',')}" }

  belongs_to :order

  def charged?
    self.state.in?(CHARGED_STATES)
  end

  def amount_in_dollars
    self.amount_in_cents / 100.0
  end

  def auth_success?
    self.state.in? AUTHED_OKAY_STATES
  end

  #def _idempotency_key
  #  Digest::MD5.hexdigest(
  #    [
  #      self.vehicle.dealer_dot_com_dealer_id,
  #      self.vehicle.vin,
  #    ].join("|")
  #  )
  #end
end
