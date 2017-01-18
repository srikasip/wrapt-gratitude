class CreateGiftDislike < ActiveRecord::Migration[5.0]
  def change
    create_table :gift_dislikes do |t|
      t.references :profile, foreign_key: true
      t.references :gift, foreign_key: true
      t.integer :reason
    end
  end
end
