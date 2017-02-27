class AddRecipientReviewedToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :recipient_reviewed, :boolean, default: false, null: false
  end
end
