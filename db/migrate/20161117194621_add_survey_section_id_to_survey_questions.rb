class AddSurveySectionIdToSurveyQuestions < ActiveRecord::Migration[5.0]
  def change
    add_reference :survey_questions, :survey_section, index: true
  end
end
