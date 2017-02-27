class AddUnmoderatedTestingPlatformToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :unmoderated_testing_platform, :boolean, default: false, null: false
  end
end
