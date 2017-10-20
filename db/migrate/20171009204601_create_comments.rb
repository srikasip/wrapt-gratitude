class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.integer :commentable_id, null: false
      t.string :commentable_type, null: false
      t.text :content, null: false
      t.references :user, foreign_key: true, index: true, null: false

      t.timestamps
    end

    add_index :comments, [:commentable_id, :commentable_type]
  end
end
