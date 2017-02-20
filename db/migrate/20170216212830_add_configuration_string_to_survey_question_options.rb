class AddConfigurationStringToSurveyQuestionOptions < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_question_options, :configuration_string, :string
  end
end
