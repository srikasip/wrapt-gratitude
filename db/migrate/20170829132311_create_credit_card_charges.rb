class CreateCreditCardCharges < ActiveRecord::Migration[5.0]
  def change
    create_table :customer_orders do |t|
      #t.references :shipping_carrier, foreign_key: true
      t.references :user, foreign_key: true, null: false
      t.references :profile, foreign_key: true, null: false

      t.string :order_number, null: false
      t.string :status, null: false

      t.string :recipient_name, null: false
      t.string :ship_address_1, null: false
      t.string :ship_address_2
      t.string :ship_address_3
      t.string :ship_city, null: false
      t.string :ship_region, null: false
      t.string :ship_postal_code, null: false
      t.string :ship_country, null: false
      t.text :notes

      t.decimal :customer_shipping_cost_in_dollars
      t.decimal :actual_shipping_cost_in_dollars
      t.decimal :total_price_in_dollars

      t.date :created_on, null: false
      t.timestamps
    end

    create_table :purchase_orders do |t|
      t.references :vendor, foreign_key: true
      t.references :customer_order, foreign_key: true
      t.timestamps
    end

    create_table :line_items do |t|
      #t.references :gift, foreign_key: true
      #t.references :product, foreign_key: true

      t.integer :orderable_id, null: false
      t.string :orderable_type, null: false

      #t.references :order, foreign_key: true, null: false
      t.integer :order_id, null: false
      t.string :order_type, null: false

      #t.references :purchase_order, foreign_key: true, null: false

      t.boolean :accounted_for_in_inventory, null: false, default: false
      t.decimal :price_per_each_in_dollars
      t.integer :quantity
      t.decimal :total_price_in_dollars
      t.timestamps
    end

    create_table :charges do |t|
      t.references :customer_order, foreign_key: true

      t.integer :charge_id
      t.string :state
      t.text :description
      t.integer :amount_in_cents
      t.datetime :payment_made_at
      t.datetime :declined_at
      t.string :idempotency_key
      t.datetime :idempotency_key_expires_at
      t.text :error_message
      t.jsonb :metadata
      t.string :token
      t.string :error_code
      t.string :error_param
      t.string :decline_code
      t.string :error_type
      t.string :http_status
      t.integer :amount_refunded_in_cents
      t.datetime :authed_at
      t.timestamps
    end

    create_table :shipping_carriers do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :parcels do |t|
      t.string :description, null: false
      t.decimal :length_in_inches, null: false
      t.decimal :width_in_inches, null: false
      t.decimal :height_in_inches, null: false
      t.timestamps
    end

    create_table :shipments do |t|
      t.references :customer_order, foreign_key: true
      t.references :purchase_order, foreign_key: true
      t.jsonb :address_from
      t.jsonb :address_to
      t.jsonb :parcel
      t.jsonb :api_response
      t.boolean :success
      t.timestamps
    end

    create_table :shipping_labels do |t|
      t.references :shipment, foreign_key: true
      #t.references :purchase_order, foreign_key: true

      t.string :tracking_number
      t.jsonb :api_response
      t.boolean :success
      t.text :url
      t.string :shippo_object_id
      t.text :error_messages
      t.timestamps
    end
  end
end
