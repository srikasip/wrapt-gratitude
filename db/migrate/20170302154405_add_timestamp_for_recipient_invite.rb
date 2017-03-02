class AddTimestampForRecipientInvite < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :recipient_invited_at, :datetime
    add_index :profiles, :recipient_invited_at
    add_index :gift_likes, :created_at
  end
end
