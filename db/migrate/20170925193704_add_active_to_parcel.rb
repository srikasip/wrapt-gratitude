class AddActiveToParcel < ActiveRecord::Migration[5.0]
  def change
    add_column :parcels, :active, :boolean, default: true, null: false
  end
end
