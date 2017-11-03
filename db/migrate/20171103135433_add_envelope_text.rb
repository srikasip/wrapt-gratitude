class AddEnvelopeText < ActiveRecord::Migration[5.0]
  def change
    add_column :customer_orders, :note_envelope_text, :string
  end
end
