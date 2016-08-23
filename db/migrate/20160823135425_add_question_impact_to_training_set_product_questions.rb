class AddQuestionImpactToTrainingSetProductQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :training_set_product_questions, :question_impact, :float, null: false, default: 0.0
  end
end
