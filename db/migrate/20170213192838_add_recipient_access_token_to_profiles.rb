class AddRecipientAccessTokenToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :recipient_access_token, :string
    Profile.all.each do |profile|
      profile.generate_recipient_access_token
      profile.save validate: false
    end
  end
end
