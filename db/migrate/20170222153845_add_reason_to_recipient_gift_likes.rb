class AddReasonToRecipientGiftLikes < ActiveRecord::Migration[5.0]
  def change
    add_column :recipient_gift_likes, :reason, :integer
  end
end
