module Admin
  class InvitationRequestsController < BaseController
    
    def index
      @invitation_requests = InvitationRequest
        .pending
        .page(params[:page])
        .per(50)
    end
    
    def update
      # Convert them to a user invitation
      @invitation_request = InvitationRequest.find params[:id]
      @user = @invitation_request.to_user
      @user.setup_activation
      @user.source = :requested_invitation
      if @user.save
        @invitation_request.update invited_user: @user
        UserActivationsMailer.activation_needed_email(@user).deliver_later
        flash.notice = "Sent an account invitation to #{@user.email}.  They can now be found in the main user section."
        redirect_to admin_invitation_requests_path
      else
        redirect_to({action: :index}, alert: "Sorry, we were unable to invite #{@user.email}.  Does a user with that email address already exist?")
      end
    end

    def destroy
      @invitation_request = InvitationRequest.find params[:id]
      @invitation_request.destroy
      flash.notice = "Deleted request from #{@invitation_request.email}"
      redirect_to admin_invitation_requests_path
    end

    def active_top_nav_section
      'users'      
    end
    helper_method :active_top_nav_section
      
  end
end