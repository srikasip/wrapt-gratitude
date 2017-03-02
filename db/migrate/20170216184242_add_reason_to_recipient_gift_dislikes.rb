class AddReasonToRecipientGiftDislikes < ActiveRecord::Migration[5.0]
  def change
    add_column :recipient_gift_dislikes, :reason, :integer
  end
end
