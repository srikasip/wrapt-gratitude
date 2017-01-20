class AddCompletedAtToSurveyResponses < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_responses, :completed_at, :datetime
  end
end
