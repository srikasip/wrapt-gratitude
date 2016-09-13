class CreateGiftProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :gift_products do |t|
      t.references :gift, foreign_key: true
      t.references :product, foreign_key: true

      t.timestamps
    end
  end
end
