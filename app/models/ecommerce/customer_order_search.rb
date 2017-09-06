class CustomerOrderSearch < Struct.new(:params)
  def results
    search_params = params[:search]

    base_scope = CustomerOrder.all

    if search_params[:order_number].present?
      base_scope = base_scope.where("order_number ilike ?", '%'+search_params[:order_number].strip+'%')
    end

    if search_params[:created_on].present?
      base_scope = base_scope.where("created_on = ?", search_params[:created_on])
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
