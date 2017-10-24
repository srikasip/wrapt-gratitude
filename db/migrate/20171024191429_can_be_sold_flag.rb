class CanBeSoldFlag < ActiveRecord::Migration[5.0]
  def  up
    add_column :gifts, :can_be_sold, :boolean, default: false, null: false

    begin
      say_with_time "updating can-be-sold flag" do
        Gift.find_each do |gift|
          gift.save
        end
      end
    rescue Exception => e
      puts "Data migration failed in #{__FILE__}: #{e.message}"
    end
  end

  def down
    remove_column :gifts, :can_be_sold
  end
end
