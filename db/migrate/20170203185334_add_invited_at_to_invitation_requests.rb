class AddInvitedAtToInvitationRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :invitation_requests, :invited_at, :datetime, index: true
  end
end
