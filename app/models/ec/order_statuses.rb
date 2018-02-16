module Ec
  module OrderStatuses
    extend ActiveSupport::Concern

    VALID_ORDER_STATUSES = [
      ORDER_INITIALIZED   = 'initialized',
      SUBMITTED           = 'submitted',
      APPROVED            = 'approved',    # Vendors acknowledged they can fulfill order
      PROCESSING          = 'processing',
      SHIPPED             = 'shipped',
      RECEIVED            = 'received',
      CANCELLED           = 'cancelled',
      PARTIALLY_CANCELLED = 'partially_cancelled', # Not available for purchase orders.
      FAILED              = 'failed',
    ]

    COMPLETED_STATUSES = [
      RECEIVED,
      CANCELLED,
      PARTIALLY_CANCELLED,
      FAILED
    ]
    
    PURCHASED = [SUBMITTED, APPROVED, PROCESSING, SHIPPED, RECEIVED]

    SHIPPED_OR_BETTER = [SHIPPED, RECEIVED]

    NOT_COMPLETED_STATUSES = VALID_ORDER_STATUSES - COMPLETED_STATUSES

    CANCELABLE_STATUSES = VALID_ORDER_STATUSES - [ORDER_INITIALIZED, CANCELLED, PARTIALLY_CANCELLED, FAILED]

    define_method(:shipped_or_better?) { self.status.in?(SHIPPED_OR_BETTER) }
    define_method(:received?)          { self.status == RECEIVED }
    define_method(:cancelled?)         { self.status == CANCELLED }
    define_method(:cancelable?)        { self.status.in?(CANCELABLE_STATUSES) }

    included do |klass|
      if klass.respond_to?(:scope)
        scope :recancelable, -> { where(status: [CANCELLED, PARTIALLY_CANCELLED, FAILED]) }
      end
    end
  end
end
