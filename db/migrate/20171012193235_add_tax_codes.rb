class AddTaxCodes < ActiveRecord::Migration[5.0]
  def change
    create_table :tax_codes do |t|
      t.boolean :active, default: true, null: false
      t.string :name, null: false
      t.text :description, null: false
      t.string :code, null: false

      t.timestamps
    end

    add_index :tax_codes, :code, unique: true

    add_reference :gifts, :tax_code, foreign_key: true, index: true
  end
end
