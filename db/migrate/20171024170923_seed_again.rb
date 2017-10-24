class SeedAgain < ActiveRecord::Migration[5.0]
  def up
    load 'db/seeds.rb'
  end
end
