class AddPublishedToSurveys < ActiveRecord::Migration[5.0]
  def change
    add_column :surveys, :published, :boolean, index: true
  end
end
