class CreditCardExtraInfo < ActiveRecord::Migration[5.0]
  def change
    add_column :charges, :bill_zip, :string
    add_column :charges, :last_four, :string, limit: 4
    add_column :charges, :card_type, :string
  end
end
