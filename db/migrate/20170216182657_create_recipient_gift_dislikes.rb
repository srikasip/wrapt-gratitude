class CreateRecipientGiftDislikes < ActiveRecord::Migration[5.0]
  def change
    create_table :recipient_gift_dislikes do |t|
      t.references :gift, index: true
      t.references :profile, index: true

      t.timestamps
    end
  end
end
