class AddSectionIntroductionTextToSurveySections < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_sections, :introduction_heading, :text
    add_column :survey_sections, :introduction_text, :text
  end
end
