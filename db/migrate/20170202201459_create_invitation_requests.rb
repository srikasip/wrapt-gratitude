class CreateInvitationRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :invitation_requests do |t|
      t.string :email

      t.timestamps
    end
  end
end
