module Admin
  class UsersController < BaseController
    before_filter :find_user, only: [:edit, :update, :destroy, :resend_invitation]
  
    def index
      @user_search = UserSearch.new(user_search_params)
      @users = User
        .all
        .search(user_search_params)
        .order(:last_name, :first_name)
        .page(params[:page])
        .per(50)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new user_params
      @user.setup_activation
      @user.source = :admin_invitation
      if @user.save
        UserActivationsMailer.activation_needed_email(@user).deliver_later
        flash[:notice] = "Sent an account invitation to #{@user.full_name}."
        redirect_to admin_users_path
      else
        flash[:alert] = "Please correct the errors below."
        render :new
      end
    end

    def edit
    end

    def update
      if @user.update user_params
        flash[:notice] = "Updated account for #{@user.full_name}."
        redirect_to admin_users_path
      else
        flash[:alert] = "Please correct the errors below."
        render :edit
      end
    end

    def destroy
      @user.destroy
      flash[:notice] = "Deleted account for #{@user.full_name}."
      redirect_to admin_users_path(context_params)
    end

    def resend_invitation
      @user.setup_activation
      @user.save validate: false
      UserActivationsMailer.activation_needed_email(@user).deliver_later
      flash[:notice] = "Sent an account invitation to #{@user.full_name}."
      redirect_to admin_users_path(context_params)
    end
    
  
    private def user_params
      params.require(:user).permit(
        :first_name,
        :last_name,
        :email,
        :admin,
        :unmoderated_testing_platform
      )
    end
    

    private def find_user
      @user = User.find(params[:id]) if params[:id]
    end

    private def user_search_params
      params_base = params[:user_search] || ActionController::Parameters.new
      params_base.permit(:keyword, :source, :beta_round)
    end
    helper_method :user_search_params

    private def context_params
      params.permit(:page).merge(user_search: user_search_params)
    end
    helper_method :context_params

  end
end