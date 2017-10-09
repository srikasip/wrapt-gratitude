class AddMoreShippingThings < ActiveRecord::Migration[5.0]
  def change
    ShippingCarrier.truncate(true)

    add_column :shipping_carriers, :shippo_provider_name, :string, null: false

    add_column :parcels, :shippo_template_name, :string

    rename_column :customer_orders, :shippo_token_choice, :shipping_choice

    add_index :shipping_carriers, :shippo_provider_name, unique: true
    add_index :shipping_carriers, :name, unique: true

    create_table :shipping_service_levels do |t|
      t.references :shipping_carrier, foreign_key: true, null: false
      t.string :name, null: false
      t.string :shippo_token, null: false, index: :unique
      t.integer :estimated_days, null: false
      t.string :terms, null: false
      t.timestamps
    end

    create_table :vendor_service_levels do |t|
      t.references :vendor, foreign_key: true, null: false
      t.references :shipping_service_level, foreign_key: true, null: false, index: true
      t.timestamps
    end

    add_index :vendor_service_levels, [:vendor_id, :shipping_service_level_id], unique: true, name: 'vsl_vendor_id_ssl_id_unq_idx'

    reversible do |change|
      change.up do
        begin
          say_with_time "Seeding carrier data" do
            path = File.join(Rails.root, 'db', 'seeds', 'carriers.rb')
            load(path)

            path = File.join(Rails.root, 'db', 'seeds', 'parcels.rb')
            load(path)
          end
        rescue StandardError => e
          puts "Data Migration Failed: #{e.message} in #{__FILE__}"
        end
      end
    end

  end
end
