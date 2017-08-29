class CreateCreditCardCharges < ActiveRecord::Migration[5.0]
  def change
    create_table :charges do |t|
      # charge_id
      # state
      # description
      t.integer :amount_in_cents
      #payment_made_at
      t.datetime :declined_at
      #customer_mailed_at
      t.string :idempotency_key
      t.datetime :idempotency_key_expires_at
      #error_message
      t.jsonb :metadata
      t.string :token
      #error_code
      #error_param
      #decline_code
      #error_type
      #http_status
      t.integer :amount_refunded_in_cents
      #t.datetime :authed_at
      t.timestamps
    end

    create_table :shipping_carriers do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :orders do |t|
      t.references :shipping_carrier, foriegn_key: true

      t.references :user, foreign_key: true

      t.string :order_number
      t.string :status

      t.string :customer_email
      t.string :customer_name
      t.string :recipient_name
      t.string :ship_address_1
      t.string :ship_address_2
      t.string :ship_address_3
      t.string :ship_city
      t.string :ship_region
      t.string :ship_postal_code
      t.string :ship_country
      t.text :notes

      t.decimal :customer_shipping_cost_in_dollars
      t.decimal :actual_shipping_cost_in_dollars

      t.timestamps
    end

    create_table :line_items do |t|
      t.references :gift, foriegn_key: true
      t.integer :order_id
      t.boolean :accounted_for_in_inventory, null: false, default: false
      t.decimal :price_in_dollars
      t.timestamps
    end

    create_table :purchase_orders do |t|
      t.references :vendor, foriegn_key: true
      t.references :order, foreign_key: true
      t.timestamps
    end

    create_table :purchase_order_line_items do |t|
      t.references :purchase_order, foriegn_key: true
      t.references :line_item, foreign_key: true
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
      t.references :order, foriegn_key: true
      t.jsonb :api_request
      t.jsonb :api_response
      t.timestamps
    end

    create_table :shipping_labels do |t|
      t.references :shipment, foriegn_key: true
      t.references :purchase_order, foriegn_key: true
      t.string :tracking_number
      t.jsonb :api_request
      t.jsonb :api_response
      t.timestamps
    end
  end
end
