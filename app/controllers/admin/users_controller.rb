module Admin
  class UsersController < BaseController
    before_filter :find_user, only: [:edit, :update, :destroy, :resend_invitation]
  
    def index
      @users = User
        .all
        .order(:id)
        .page(params[:page])
        .per(50)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new user_params
      @user.setup_activation
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
      redirect_to admin_users_path
    end

    def resend_invitation
      @user.setup_activation
      @user.save validate: false
      UserActivationsMailer.activation_needed_email(@user).deliver_later
      flash[:notice] = "Sent an account invitation to #{@user.full_name}."
    end
    
  
    private def user_params
      params.require(:user).permit(
        :first_name,
        :last_name,
        :email,
        :admin    
      )
    end
    

    private def find_user
      @user = User.find(params[:id]) if params[:id]
    end
  end
end