class AddInvitedUserToInvitationRequests < ActiveRecord::Migration[5.0]
  def change
    add_reference :invitation_requests, :invited_user, index: true
  end
end
