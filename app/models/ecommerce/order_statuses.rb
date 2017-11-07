module OrderStatuses
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

  SHIPPED_OR_BETTER = [SHIPPED, RECEIVED]

  NOT_COMPLETED_STATUSES = VALID_ORDER_STATUSES - COMPLETED_STATUSES

  define_method(:shipped_or_better?) { self.status.in?(SHIPPED_OR_BETTER) }
  define_method(:received?)          { self.status == RECEIVED }
  define_method(:cancelled?)         { self.status == CANCELLED }
end
