class CreateProfileSetSurveyResponses < ActiveRecord::Migration[5.0]
  def change
    create_table :profile_set_survey_responses do |t|
      t.string :name
      t.references :profile_set, foreign_key: true

      t.timestamps
    end
  end
end
