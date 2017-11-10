class AddEstimateFlagForTaxTransactions < ActiveRecord::Migration[5.0]
  def change
    add_column :tax_transactions, :is_estimate, :boolean, default: false, null: false
  end
end
