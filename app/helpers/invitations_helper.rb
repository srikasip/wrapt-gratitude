module InvitationsHelper
  def with_invitation_scope path
    if params[:invitation_id]
      "/invitations/#{params[:invitation_id]}#{path}"
    else
      path
    end
  end
end
