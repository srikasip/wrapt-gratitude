class AddNewslettersFlag < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :wants_newsletter, :boolean, default: false, null: false
  end
end
