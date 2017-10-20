class AddCountryToAddress < ActiveRecord::Migration[5.0]
  def change
    add_column :addresses, :country, :string, null: false, default: 'US'
  end
end
