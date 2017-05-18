class AddTestModeFlagToSurveys < ActiveRecord::Migration[5.0]
  def change
    add_column :surveys, :test_mode, :boolean, default: false
  end
end
