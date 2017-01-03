class AddActiveToSurveys < ActiveRecord::Migration[5.0]
  def change
    add_column :surveys, :active, :boolean
  end
end
