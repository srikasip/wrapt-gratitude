class CustomerPurchase
  include ChargeConstants

  attr_accessor :stripe_token, :gifts, :our_charge, :stripe_charge

  #delegate :error_message, to: :our_charge, prefix: false

  #def initialize(buyer_agreement:, stripe_token:nil)
  #  self.buyer_agreement = buyer_agreement
  #  self.vehicle         = self.buyer_agreement.vehicle
  #  self.our_charge      = self.buyer_agreement.last_credit_card_charge
  #  self.stripe_token    = stripe_token || self.our_charge.token
  #end
  #
  #def auth_and_charge!
  #  authorize!
  #  if auth_success?
  #    charge!
  #  end
  #end
  #
  #def authorize!
  #  _sanity_check!
  #  _init_our_charge_record!
  #
  #  _safely do
  #    _do_stripe_auth!
  #    _verify_consistency!(captured: false)
  #    _save_auth_results!
  #  end
  #
  #  self.our_charge
  #end
  #
  #def auth_success?
  #  self.our_charge.state.in? AUTHED_OKAY_STATES
  #end
  #
  #def charged?
  #  self.our_charge.state.in? CHARGED_STATES
  #end
  #
  #def charge!
  #  _sanity_check!
  #
  #  _safely do
  #    _do_stripe_charge!
  #    _verify_consistency!(captured: true)
  #    _save_charge_results!
  #  end
  #
  #  _email!
  #end

  private

  def _sanity_check!
    if amount_in_dollars.to_i < MIN_CHARGE
      raise InternalConsistencyError, "Charge is too small"
    elsif gifts.empty?
      raise InternalConsistencyError, "You must have gifts to buy"
    elsif ENV['SHIPPO_TOKEN'].blank?
      raise InternalConsistencyError, "You must have a shippo token"
    elsif ENV['STRIPE_SECRET_KEY'].blank?
      raise InternalConsistencyError, "You must have a stripe token"
    end
  end

  #def _init_our_charge_record!
  #  self.our_charge = CreditCardCharge.create!({
  #    token: self.stripe_token,
  #    state: CreditCardCharge::INITIALIZED,
  #    amount_in_cents: amount_in_cents,
  #    description: _description,
  #    idempotency_key: _idempotency_key,
  #    idempotency_key_expires_at: (Time.now+1.day),
  #    dealer_site_id: self.vehicle.dealer_site.id,
  #    buyer_agreement_id: self.buyer_agreement.id,
  #    metadata: {
  #      dealer_dot_com_dealer_id: self.vehicle.dealer_dot_com_dealer_id,
  #      dealer_specialties_dealer_id: self.vehicle.ds_dealer_id,
  #      vin: self.vehicle.vin,
  #      dealer_site_id: self.vehicle.dealer_site.id
  #    }
  #  })
  #
  #  # Note, unsuccessful charges are retained, though the buyer agreement
  #  # itself points to the most recent one
  #  self.buyer_agreement.update_attribute(:credit_card_charge_id, self.our_charge.id)
  #end

  #def _do_stripe_auth!
  #  self.stripe_charge = Stripe::Charge.create(
  #    currency: CreditCardCharge::USD,
  #    source: self.our_charge.token,
  #    capture: false, # <- Do an auth. This DOES NOT charge the card
  #    amount: self.our_charge.amount_in_cents,
  #    description: self.our_charge.description,
  #    idempotency_key: self.our_charge.idempotency_key,
  #    metadata: self.our_charge.metadata
  #  )
  #end

  #def _do_stripe_charge!
  #  self.stripe_charge = Stripe::Charge.retrieve(self.our_charge.charge_id)
  #
  #  if self.stripe_charge.captured == false && (Time.now-self.our_charge.authed_at) > TIME_TO_CAPTURE
  #    raise InternalConsistencyError, "You didn't charge the auth soon enough. It must be done within 7 days"
  #  end
  #
  #  self.stripe_charge.capture
  #end

  #def _verify_consistency!(captured:)
  #  unless self.stripe_charge.status.in? GOOD_STRIPE_STATUSES
  #    raise InternalConsistencyError, "unexpected status=#{self.stripe_charge.status.to_json}"
  #  end
  #
  #  unless self.stripe_charge.captured == captured
  #    raise InternalConsistencyError, "Expected captured to be #{captured}. It wasn't"
  #  end
  #
  #  unless self.stripe_charge.paid
  #    raise InternalConsistencyError, "unexpected paid=#{self.stripe_charge.paid.to_json}"
  #  end
  #
  #  unless self.stripe_charge.outcome.type == 'authorized'
  #    raise InternalConsistencyError, "This should have been authorized"
  #  end
  #
  #  unless self.stripe_charge.id
  #    raise InternalConsistencyError, "missing id"
  #  end
  #
  #  if Rails.env.production? && !self.stripe_charge.livemode
  #    raise InternalConsistencyError, "unexpected livemode=#{self.stripe_charge.livemode.to_json}"
  #  end
  #end
  #
  #def _save_auth_results!
  #  self.our_charge.update_attributes({
  #    authed_at: Time.now,
  #    charge_id: self.stripe_charge.id,
  #    state: AUTH_SUCCEEDED
  #  })
  #end
  #
  #def _save_charge_results!
  #  self.our_charge.update_attributes({
  #    payment_made_at: Time.now,
  #    state: CHARGE_SUCCEEDED
  #  })
  #
  #  self.buyer_agreement.set_step!(BuyerAgreement::PAID)
  #end
  #
  #def _email!
  #  if self.charged?
  #    BuyerAgreementMailer.payment_success(self.our_charge.id).deliver_later
  #  end
  #end
  #
  #def amount_in_cents
  #  self.vehicle.reservation_fee * 100
  #end
  #
  #def amount_in_dollars
  #  self.vehicle.reservation_fee
  #end
  #
  #def _description
  #  "Reservation for #{self.vehicle.short_name}"
  #end
  #
  #def _idempotency_key
  #  Digest::MD5.hexdigest(
  #    [
  #      self.vehicle.dealer_dot_com_dealer_id,
  #      self.vehicle.vin,
  #    ].join("|")
  #  )
  #end

  def _safely
    yield
  #rescue Stripe::CardError => e
  #  # Since it's a decline, Stripe::CardError will be caught
  #  body = e.json_body
  #  err  = body[:error]
  #
  #  self.our_charge.update_attributes({
  #    http_status: e.http_status,
  #    error_type: err[:type],
  #    charge_id: err[:charge],
  #    error_code: err[:code],
  #    decline_code: err[:decline_code],
  #    error_param: err[:param],
  #    error_message: err[:message],
  #    state: CreditCardCharge::DECLINED,
  #    declined_at: Time.now
  #  })
  #
  #  BuyerAgreementMailer.payment_declined(self.our_charge.id).deliver_later
  #rescue Stripe::RateLimitError => e
  #  self.our_charge.update_attributes({
  #    state: CreditCardCharge::RATE_LIMIT_FAIL,
  #    error_message: e.message
  #  })
  #  BuyerAgreementMailer.payment_failure(self.our_charge.id).deliver_later
  #rescue Stripe::InvalidRequestError => e
  #  self.our_charge.update_attributes({
  #    state: CreditCardCharge::INVALID_REQUEST_FAIL,
  #    error_message: e.message
  #  })
  #  BuyerAgreementMailer.payment_failure(self.our_charge.id).deliver_later
  #rescue Stripe::AuthenticationError => e
  #  self.our_charge.update_attributes({
  #    state: CreditCardCharge::AUTHENTICATION_FAIL,
  #    error_message: e.message
  #  })
  #  BuyerAgreementMailer.payment_failure(self.our_charge.id).deliver_later
  #rescue Stripe::APIConnectionError => e
  #  self.our_charge.update_attributes({
  #    state: CreditCardCharge::API_CONNECTION_FAIL,
  #    error_message: e.message
  #  })
  #  BuyerAgreementMailer.payment_failure(self.our_charge.id).deliver_later
  #rescue RechargeError => e
  #  raise
  #rescue Exception => e
  #  self.our_charge.update_attributes({
  #    state: CreditCardCharge::INTERNAL_CONSISTENCY_FAIL,
  #    error_message: (e.message + e.backtrace.to_s)
  #  })
  #  BuyerAgreementMailer.payment_failure(self.our_charge.id).deliver_later
  end
end
