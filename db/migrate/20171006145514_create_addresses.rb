class CreateAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :addresses do |t|
      t.string :street1, null: false
      t.string :street2
      t.string :street3
      t.string :city, null: false
      t.string :state, null: false
      t.string :zip, null: false
      t.string :addressable_type, null: false
      t.integer :addressable_id, null: false

      t.timestamps
    end

    add_index :addresses, [:addressable_id, :addressable_type]
  end
end
