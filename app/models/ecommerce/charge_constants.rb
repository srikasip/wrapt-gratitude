module ChargeConstants
  USD = 'usd'

  MIN_CHARGE = 5 # usd (dollars)

  RechargeError = Class.new(StandardError)

  VALID_STATES = [
    INITIALIZED               = 'initialized',

    RATE_LIMIT_FAIL           = 'rate_limit_failure',
    INVALID_REQUEST_FAIL      = 'invalid_request_failure',
    AUTHENTICATION_FAIL       = 'authentication_failure',
    API_CONNECTION_FAIL       = 'api_connection_failure',
    INTERNAL_CONSISTENCY_FAIL = 'internal_consistency_failure',

    DECLINED                  = 'declined',

    AUTH_SUCCEEDED            = 'auth_succeeded',
    CHARGE_SUCCEEDED          = 'charge_succeeded',
    EMAILED_SUCCESS           = 'emailed_success',
  ]

  AUTHED_OKAY_STATES = [
    AUTH_SUCCEEDED,
    CHARGE_SUCCEEDED,
    EMAILED_SUCCESS
  ]

  CHARGED_STATES = [
    CHARGE_SUCCEEDED,
    EMAILED_SUCCESS
  ]

  GOOD_STRIPE_STATUSES = [
    PAID      = 'paid',
    SUCCEEDED = 'succeeded'
  ]

  # After an auth, must charge within this timespan
  TIME_TO_CAPTURE = 7.days

  SHIPPO_SUCCESS = 'SUCCESS'
end
