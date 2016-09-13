class CreateGifts < ActiveRecord::Migration[5.0]
  def change
    create_table :gifts do |t|
      t.string :name
      t.text :description
      t.decimal :selling_price, precision: 10, scale: 2
      t.decimal :cost, precision: 10, scale: 2
      t.string :wrapt_sku
      t.date :date_available
      t.date :date_discontinued

      t.timestamps
    end
  end
end
