class AddSourceAndBetaRoundToUsers < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      CREATE TYPE user_source AS ENUM ('admin_invitation', 'requested_invitation', 'recipient_referral');
    SQL

    add_column :users, :source, :user_source, index: true

    User.update_all source: :admin_invitation

    execute <<-SQL
      CREATE TYPE beta_round AS ENUM ('pre_release_testing', 'mvp1a');
    SQL

    add_column :users, :beta_round, :beta_round, index: true

    User.update_all beta_round: :pre_release_testing
    
  end

  def down
    remove_column :users, :source
    remove_column :users, :beta_round

    execute <<-SQL
      DROP TYPE user_source;
      DROP TYPE beta_round
    SQL
  end
end
