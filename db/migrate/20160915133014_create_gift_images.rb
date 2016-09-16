class CreateGiftImages < ActiveRecord::Migration[5.0]
  def change
    create_table :gift_images do |t|
      t.references :gift, foreign_key: true
      t.string :image

      t.timestamps
    end
  end
end
