class CreateSurveyResponses < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_responses do |t|
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
