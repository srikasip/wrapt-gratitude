class AddRecipientReferringProfileToUsers < ActiveRecord::Migration[5.0]
  def change
    add_reference :users, :recipient_referring_profile
  end
end
