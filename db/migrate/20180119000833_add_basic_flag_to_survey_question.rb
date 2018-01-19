class AddBasicFlagToSurveyQuestion < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_questions, :basic, :boolean, default: false, null: false
  end
end
