class AllowNullForRangeImpactDirectCorrelation < ActiveRecord::Migration[5.0]
  def change
    change_column_null :gift_question_impacts, :range_impact_direct_correlation, true, true
  end
end
