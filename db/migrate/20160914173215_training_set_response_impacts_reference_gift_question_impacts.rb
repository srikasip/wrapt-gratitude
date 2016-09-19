class TrainingSetResponseImpactsReferenceGiftQuestionImpacts < ActiveRecord::Migration[5.0]
  def change
    TrainingSetResponseImpact.delete_all
    remove_column :training_set_response_impacts, :training_set_product_question_id
    change_table :training_set_response_impacts do |t|
      t.references :gift_question_impact, foreign_key: true, null: false
    end
  end
end
