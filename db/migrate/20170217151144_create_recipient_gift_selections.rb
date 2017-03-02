class CreateRecipientGiftSelections < ActiveRecord::Migration[5.0]
  def change
    create_table :recipient_gift_selections do |t|
      t.references :profile, index: true
      t.references :gift, index: true

      t.timestamps
    end
  end
end
