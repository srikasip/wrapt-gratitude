class CreateFileExports < ActiveRecord::Migration[5.0]
  def change
    create_table :file_exports do |t|
      t.string :asset, null: false
      t.string :asset_type, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :file_exports, :asset_type
    add_index :file_exports, :created_at, order: :desc
  end
end
