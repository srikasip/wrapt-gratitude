module Ec
  class CustomerOrderSearch < Struct.new(:params)
    def results
      search_params = params[:search]

      base_scope = CustomerOrder.all

      if search_params[:order_number].present?
        base_scope = base_scope.where("order_number ilike ?", '%'+search_params[:order_number].strip+'%')
      end

      if search_params[:updated_at].present?
        start_datetime = Date.parse(search_params[:updated_at])
        end_datetime = start_datetime.tomorrow
        base_scope = base_scope.where("created_at between ? AND ?", start_datetime, end_datetime)
      end

      if search_params[:email].present?
        base_scope = base_scope.where({
          user_id: User.select(:id).where("users.email ilike ?", '%'+search_params[:email].strip+'%')
        })
      end

      if search_params[:status].present?
        base_scope = base_scope.where(status: search_params[:status].keys)
      end

      base_scope.order('created_at desc').preload(:user, :line_items => :orderable).page(params[:page])
    end
  end
end
