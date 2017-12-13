class AdjustmentFieldForTaxTransactions < ActiveRecord::Migration[5.0]
  def change
    add_column :tax_transactions, :api_adjustment_response, :jsonb
    rename_column :tax_transactions, :api_response, :api_estimation_response
  end
end
