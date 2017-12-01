class CreatePromoCodes < ActiveRecord::Migration[5.0]
  def change
    create_table :promo_codes do |t|
      t.string :value, null: false
      t.text :description, null: false, default: 'no description'
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :amount, null: false
      t.string :mode, null: false

      t.timestamps
    end

    add_index :promo_codes, :value, unique: true
    add_index :promo_codes, [:start_date, :end_date]
  end
end
