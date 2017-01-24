class CreateGiftSelections < ActiveRecord::Migration[5.0]
  def change
    create_table :gift_selections do |t|
      t.references :profile, foreign_key: true
      t.references :gift, foreign_key: true

      t.timestamps
    end
  end
end
