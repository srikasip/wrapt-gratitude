class RemovePublicFromProducts < ActiveRecord::Migration[5.0]
  def change
    remove_column :products, :public, :boolean
  end
end
