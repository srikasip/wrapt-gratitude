class CreateSurveyResponseTraitEvaluations < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'hstore'
    create_table :survey_response_trait_evaluations do |t|
      t.references :response, index: true
      t.references :trait_training_set, index: {name: 'index_response_trait_evals_on_trait_training_set'}
      t.hstore :matched_tag_id_counts, default: {}

      t.timestamps
    end
    add_index :survey_response_trait_evaluations, :matched_tag_id_counts, using: :gin, name: 'index_trait_evaluations_on_matched_tag_id_counts'
  end
end
