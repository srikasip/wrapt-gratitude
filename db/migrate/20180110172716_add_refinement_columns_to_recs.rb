class AddRefinementColumnsToRecs < ActiveRecord::Migration[5.0]
  def change
    add_column :gift_recommendation_sets, :generation_number, :integer, null: false, default: 0
    add_column :gift_recommendations, :viewed, :boolean, null: false, default: false
  end
end
