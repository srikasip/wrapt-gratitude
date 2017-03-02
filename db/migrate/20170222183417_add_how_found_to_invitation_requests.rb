class AddHowFoundToInvitationRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :invitation_requests, :how_found, :string
  end
end
