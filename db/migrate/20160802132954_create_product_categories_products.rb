class CreateProductCategoriesProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :product_categories_products do |t|
      t.references :product_category, index: true
      t.references :product, index: true

      t.timestamps
    end
  end
end
