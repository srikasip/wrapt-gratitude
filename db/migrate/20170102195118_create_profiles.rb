class CreateProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :profiles do |t|
      t.string :email
      t.string :name
      t.integer :owner_id

      t.timestamps
    end

    add_foreign_key :profiles, :users, column: :owner_id
  end
end
