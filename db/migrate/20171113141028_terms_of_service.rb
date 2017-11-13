class TermsOfService < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :terms_of_service_accepted, :boolean, default: true, null: false

    User.update_all(terms_of_service_accepted: false)
  end

  def down
    remove_column :users, :terms_of_service_accepted
  end
end
