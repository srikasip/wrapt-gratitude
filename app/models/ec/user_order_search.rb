# For use by site users for their own orders. See
# CustomerOrderSearch for admins searching for orders.

module Ec
  class UserOrderSearch < Struct.new(:user, :params)
    include OrderStatuses

    def results
      search_params = params[:search] || {}

      # User's own orders that at least got to auth state
      base_scope = self.user.customer_orders.
        where('status != ?', ORDER_INITIALIZED)

      if search_params[:filter].present?
        case search_params[:filter]
        when 'all'
          :no_op
        when 'open'
          base_scope = base_scope.where(status: NOT_COMPLETED_STATUSES)
        when 'completed'
          base_scope = base_scope.where(status: COMPLETED_STATUSES)
        else
          :no_op
        end
      end

      base_scope.order('submitted_on desc, created_at desc')
        .preload(:profile, :purchase_orders => {shipment: :shipping_label}).
         page(params[:page])
    end
  end
end
