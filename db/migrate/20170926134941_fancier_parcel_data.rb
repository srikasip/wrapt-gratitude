class FancierParcelData < ActiveRecord::Migration[5.0]
  def up
    add_column :parcels, :case_pack, :integer
    add_column :parcels, :color, :string
    add_column :parcels, :source, :string
    add_column :parcels, :stock_number, :string
    add_column :parcels, :usage, :string, null: false, default: 'pretty'
    add_column :parcels, :code, :string

    begin
      Parcel.destroy_all
      CustomerOrder.destroy_all
      load File.join(Rails.root, 'db', 'seeds', 'parcels.rb')
    rescue StandardError => e
      puts "DATA MIGRATION FAILED in #{__FILE__}: #{e.message}"
    end
  end

  def down
    remove_column :parcels, :case_pack
    remove_column :parcels, :color
    remove_column :parcels, :source
    remove_column :parcels, :stock_number
    remove_column :parcels, :usage
    remove_column :parcels, :code
  end
end
