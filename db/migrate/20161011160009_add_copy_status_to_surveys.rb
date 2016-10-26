class AddCopyStatusToSurveys < ActiveRecord::Migration[5.0]
  def change
    add_column :surveys, :copy_in_progress, :boolean, default: false, null: false
  end
end
