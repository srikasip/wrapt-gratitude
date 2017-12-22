class AddExpertNoteToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :expert_note, :text
  end
end
