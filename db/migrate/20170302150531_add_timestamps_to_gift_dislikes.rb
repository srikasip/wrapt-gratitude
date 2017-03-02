class AddTimestampsToGiftDislikes < ActiveRecord::Migration[5.0]
  def change
    add_column :gift_dislikes, :created_at, :datetime
    add_index :gift_dislikes, :created_at
    add_index :gift_selections, :created_at
    add_index :profiles, :created_at
    add_index :survey_question_responses, :answered_at
    add_index :survey_responses, :completed_at
  end
end
