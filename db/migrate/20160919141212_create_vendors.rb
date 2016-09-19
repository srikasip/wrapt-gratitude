class CreateVendors < ActiveRecord::Migration[5.0]
  def change
    create_table :vendors do |t|
      t.string :name
      t.text :address
      t.string :contact_name
      t.string :email
      t.string :phone
      t.text :notes

      t.timestamps
    end
  end
end
