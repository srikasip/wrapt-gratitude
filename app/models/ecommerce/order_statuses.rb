module OrderStatuses
  VALID_ORDER_STATUSES = [
    ORDER_INITIALIZED   = 'initialized',
    SUBMITTED           = 'submitted',
    APPROVED            = 'approved',    # Vendors acknowedged they can fulfill order
    PROCESSING          = 'processing',
    SHIPPED             = 'shipped',
    RECEIVED            = 'received',
    CANCELLED           = 'cancelled',
    PARTIALLY_CANCELLED = 'partially_cancelled', # Not available for purchase orders.
    FAILED              = 'failed',
  ]
end
