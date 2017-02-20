class AddFilterFlagsToQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :survey_questions, :price_filter, :boolean, default: false
    add_column :survey_questions, :category_filter, :boolean, default: false
  end
end
