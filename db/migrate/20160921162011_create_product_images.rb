class CreateProductImages < ActiveRecord::Migration[5.0]
  def change
    create_table :product_images do |t|
      t.references :product, foreign_key: true, index: true
      t.string :image
      t.integer :sort_order, null: false, default: 0
      t.boolean :primary, index: true

      t.timestamps
    end
  end
end
