class TaxTransactionRefactor < ActiveRecord::Migration[5.0]
  def change
    add_column :tax_transactions, :api_capture_response, :jsonb
    add_column :tax_transactions, :captured, :boolean, default: false, null: false
    change_column_null :tax_transactions, :api_estimation_response, true
  end
end
