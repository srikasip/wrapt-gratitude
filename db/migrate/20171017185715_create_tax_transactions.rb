class CreateTaxTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :tax_transactions do |t|
      t.string :cart_id, null: false
      t.references :customer_order, foreign_key: true, index: true
      t.string :transaction_code
      t.jsonb :api_request_payload, null: false
      t.jsonb :api_response, null: false
      t.jsonb :api_reconcile_response
      t.boolean :reconciled, null: false, default: false
      t.boolean :success, null: false, default: false
      t.numeric :tax_in_dollars, null: false, default: 0

      t.timestamps
    end
  end
end
