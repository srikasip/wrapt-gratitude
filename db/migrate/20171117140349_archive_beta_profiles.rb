class ArchiveBetaProfiles < ActiveRecord::Migration[5.0]
  def up
    add_column :profiles, :archived_at, :datetime
    
    Profile.reset_column_information
    
    # archive old profiles
    Profile.where('created_at < ?', Time.new(2017, 10, 15)).update_all(archived_at: Time.now)
    
    # detach active profile (if archived) from user
    User.where(last_viewed_profile_id: Profile.archived).update_all(last_viewed_profile_id: nil)
  end
  
  def down
    remove_column :profiles, :archived_at
  end
end
