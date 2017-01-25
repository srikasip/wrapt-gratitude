class AddLastViewedProfileIdToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_viewed_profile_id, :integer
  end
end
