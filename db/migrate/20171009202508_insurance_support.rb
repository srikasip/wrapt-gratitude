class InsuranceSupport < ActiveRecord::Migration[5.0]
  def change
    add_column :gifts, :insurance_in_dollars, :integer

    add_column :shipments, :insurance_in_dollars, :integer
    add_column :shipments, :description_of_what_to_insure, :string
  end
end
