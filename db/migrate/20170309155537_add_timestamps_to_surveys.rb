class AddTimestampsToSurveys < ActiveRecord::Migration[5.0]
  def change
    add_column :surveys, :created_at, :datetime
    add_column :surveys, :updated_at, :datetime
  end
end
