class ServiceLevelActive < ActiveRecord::Migration[5.0]
  def change
    add_column :shipping_service_levels, :active, :boolean, default: true, null: false
  end
end
