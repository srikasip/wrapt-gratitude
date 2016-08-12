class AddRangeImpactDirectCorrelationToTrainingSetProductQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :training_set_product_questions, :range_impact_direct_correlation, :boolean, null: false, default: true
  end
end
