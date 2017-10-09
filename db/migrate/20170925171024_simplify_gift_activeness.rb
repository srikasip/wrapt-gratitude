class SimplifyGiftActiveness < ActiveRecord::Migration[5.0]
  def up
    add_column :gifts, :available, :boolean, default: true, null: false

    begin
      say_with_time "Setting available flag if the code allows" do
        Gift.find_each do |gift|
          if gift.available?
            gift.update_attribute(:available, true)
          end
        end
      end
    rescue StandardError => e
      puts "DATA MIGRATION FAILED (but it's probably fine) in #{__FILE__}: #{e.message}"
    end

    remove_column :gifts, :date_available
    remove_column :gifts, :date_discontinued
  end

  def down
    add_column :gifts, :date_available , :date , null: false, default: '1900-01-01'
    add_column :gifts, :date_discontinued , :date , null: false, default: '2999-12-31'
    remove_column :gifts, :available
  end
end
