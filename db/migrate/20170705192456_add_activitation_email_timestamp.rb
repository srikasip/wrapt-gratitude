class AddActivitationEmailTimestamp < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :activation_token_generated_at, :datetime
    
    User.update_all("activation_token_generated_at = created_at")
  end
  
  def down
    remove_column :users, :activation_token_generated_at
  end
end
