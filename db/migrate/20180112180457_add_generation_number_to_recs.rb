class AddGenerationNumberToRecs < ActiveRecord::Migration[5.0]
  def change
    add_column :gift_recommendations, :generation_number, :integer, null: false, default: 0
  end
end
