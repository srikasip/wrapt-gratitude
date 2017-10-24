class SeedAgain < ActiveRecord::Migration[5.0]
  def up
    begin
      say_with_time "seeding" do
        load 'db/seeds.rb'
      end
    rescue Exception => e
      puts "Data migration failed in #{__FILE__}: #{e.message}"
    end
  end
end
