class PurchaseService::ChargingService
  include ChargeConstants

  attr_accessor :cart_id, :customer_order, :our_charge, :stripe_charge

  def initialize(cart_id:, customer_order:nil)
    self.cart_id        = cart_id
    self.our_charge     = Charge.where(cart_id: self.cart_id).first_or_initialize
    self.customer_order = customer_order || CustomerOrder.find_by(cart_id: self.cart_id)
  end

  def init_our_charge_record!(params)
    whitelisted_params = params.permit(:stripeToken, "address-zip".to_sym, :brand, :last_four)

    if whitelisted_params[:stripeToken].blank?
      raise InternalConsistencyError, "You must have a stripe token to even think of charging a card"
    end

    if self.our_charge.charged?
      raise InternalConsistencyError, "Initing a charge record, but it's already been charged."
    end

    customer_order.reload

    our_charge.assign_attributes({
      token: whitelisted_params[:stripeToken],
      last_four: whitelisted_params[:last_four],
      card_type: whitelisted_params[:brand],
      customer_order: customer_order,
      status: INITIALIZED,
      amount_in_cents: customer_order.total_to_charge_in_cents,
      description: "Gifts for #{customer_order.profile_name}",
      idempotency_key: SecureRandom.hex(10),
      idempotency_key_expires_at: (Time.now+1.day),
      metadata: {
        user_id: customer_order.user_id,
        profile_id: customer_order.profile_id,
        gifts: customer_order.gifts.map(&:name).join('; '),
        customer_order_number: customer_order.order_number
      },
      bill_zip:  whitelisted_params['address-zip'.to_sym]
    })

    self.our_charge.save!
  end

  def authorize!(before_hook: ->{}, after_hook: ->{})
    _sanity_check!(:auth)

    _safely do
      before_hook.call
      _do_stripe_auth!
      _verify_consistency!(captured: false)

      if self.stripe_charge.outcome.type == 'authorized'
        _save_auth_results!
        after_hook.call
      else
        self.our_charge.update_attributes({
          status: DECLINED,
          error_message: "Do not honor card. outcome type was not authorized"
        })
      end
    end

    self.our_charge
  end

  def card_authorized?
    self.our_charge.status == AUTH_SUCCEEDED
  end

  def charge!(before_hook: ->{}, after_hook: ->{})
    _sanity_check!(:charge)

    _safely do
      before_hook.call

      _do_stripe_charge!
      _verify_consistency!(captured: true)
      _save_charge_results!

      after_hook.call
    end
  end

  def authed?
    our_charge.status == 'auth_succeeded'
  end

  def charged?
    our_charge.status == 'charge_succeeded'
  end

  def authed_or_charged?
    authed? || charged?
  end

  private

  def _sanity_check! meth
    if ENV['STRIPE_SECRET_KEY'].blank?
      raise InternalConsistencyError, "You must have a stripe token"
    elsif ENV['STRIPE_SECRET_KEY'].match(/live/) && !Rails.env.production?
      raise InternalConsistencyError, <<~EOS
        Comment out these lines if you really want to use the production stripe
        key outside of production
      EOS
    elsif ENV['STRIPE_SECRET_KEY'].match(/test/) && Rails.env.production?
      raise InternalConsistencyError, <<~EOS
        Comment out these lines if you really want to use test mode for stripe
        on production
      EOS
    elsif self.cart_id.blank?
      raise InternalConsistencyError, "You must have a context for the purchase (cart ID)"
    elsif authed_or_charged? && meth==:auth
      raise InternalConsistencyError, "You cannot auth more than once"
    elsif charged? && meth==:charge
      raise InternalConsistencyError, "You cannot charge more than once"
    end
  end

  def _do_stripe_auth!
    self.stripe_charge = Stripe::Charge.create(
      {
        currency: USD,
        source: our_charge.token,
        capture: false, # <- Do an auth. This DOES NOT charge the card
        amount: our_charge.amount_in_cents,
        description: our_charge.description,
        metadata: our_charge.metadata
      },{
        idempotency_key: our_charge.idempotency_key
      }
    )
  end

  def _do_stripe_charge!
    self.stripe_charge = Stripe::Charge.retrieve(self.our_charge.charge_id)

    if self.stripe_charge.captured == false && (Time.now-self.our_charge.authed_at) > TIME_TO_CAPTURE
      raise InternalConsistencyError, "You didn't charge the auth soon enough. It must be done within 7 days"
    end

    self.stripe_charge.capture
  end

  def _verify_consistency!(captured:)
    unless self.stripe_charge.status.in? GOOD_STRIPE_STATUSES
      raise InternalConsistencyError, "unexpected status=#{self.stripe_charge.status.to_json}"
    end

    unless self.stripe_charge.captured == captured
      raise InternalConsistencyError, "Expected captured to be #{captured}. It wasn't"
    end

    unless self.stripe_charge.paid
      raise InternalConsistencyError, "unexpected paid=#{self.stripe_charge.paid.to_json}"
    end

    unless self.stripe_charge.id
      raise InternalConsistencyError, "missing id"
    end

    if Rails.env.production? && !self.stripe_charge.livemode
      raise InternalConsistencyError, "unexpected livemode=#{self.stripe_charge.livemode.to_json}"
    end
  end

  def _save_auth_results!
    self.our_charge.update_attributes({
      authed_at: Time.now,
      charge_id: self.stripe_charge.id,
      status: AUTH_SUCCEEDED,
      error_code: nil,
      error_param: nil,
      decline_code: nil,
      error_type: nil,
      http_status: "200",
    })

    self.customer_order.update_attribute(:status, CustomerOrder::SUBMITTED)
  end

  def _save_charge_results!
    self.our_charge.update_attributes({
      payment_made_at: Time.now,
      status: CHARGE_SUCCEEDED
    })

    self.customer_order.update_attribute(:status, CustomerOrder::PROCESSING)
  end

  def _safely
    Charge.transaction do
      yield
    end
  rescue Stripe::CardError => e
    # Since it's a decline, Stripe::CardError will be caught
    body = e.json_body
    err  = body[:error]

    self.our_charge.update_attributes({
      http_status: e.http_status,
      error_type: err[:type],
      charge_id: err[:charge],
      error_code: err[:code],
      decline_code: err[:decline_code],
      error_param: err[:param],
      error_message: err[:message],
      status: DECLINED,
      declined_at: Time.now
    })

    self.customer_order.update_attribute(:status, CustomerOrder::FAILED)
  rescue Stripe::RateLimitError => e
    self.our_charge.update_attributes({
      status: RATE_LIMIT_FAIL,
      error_message: e.message
    })
    self.customer_order.update_attribute(:status, CustomerOrder::FAILED)
  rescue Stripe::InvalidRequestError => e
    self.our_charge.update_attributes({
      status: INVALID_REQUEST_FAIL,
      error_message: e.message
    })
    self.customer_order.update_attribute(:status, CustomerOrder::FAILED)
  rescue Stripe::AuthenticationError => e
    self.our_charge.update_attributes({
      status: AUTHENTICATION_FAIL,
      error_message: e.message
    })
    self.customer_order.update_attribute(:status, CustomerOrder::FAILED)
  rescue Stripe::APIConnectionError => e
    self.our_charge.update_attributes({
      status: API_CONNECTION_FAIL,
      error_message: e.message
    })
    self.customer_order.update_attribute(:status, CustomerOrder::FAILED)
  rescue RechargeError => e
    raise
  rescue Exception => e
    if self.our_charge.present?
      self.our_charge.update_attributes({
        status: INTERNAL_CONSISTENCY_FAIL,
        error_message: (e.message + e.backtrace.to_s)
      })
    end
    if self.customer_order.present? && self.customer_order.persisted?
      self.customer_order.update_attribute(:status, CustomerOrder::FAILED)
    end
    raise
  end
end
