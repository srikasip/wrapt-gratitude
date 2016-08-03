class CreateTrainingSetResponseImpacts < ActiveRecord::Migration[5.0]
  def change
    create_table :training_set_response_impacts do |t|
      t.references :training_set_product_question, index: {name: 'index_response_impacts_pq_id'}
      t.references :survey_question_option, index: {name: 'index_response_impacts_option_id'}
      t.integer :impact, default: 0, null: false

      t.timestamps
    end
  end
end
