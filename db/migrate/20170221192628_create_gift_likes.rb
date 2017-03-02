class CreateGiftLikes < ActiveRecord::Migration[5.0]
  def change
    create_table :gift_likes do |t|
      t.references :gift, foreign_key: true
      t.references :profile, foreign_key: true

      t.timestamps
    end
  end
end
