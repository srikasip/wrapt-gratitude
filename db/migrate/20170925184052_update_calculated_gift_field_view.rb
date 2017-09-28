class UpdateCalculatedGiftFieldView < ActiveRecord::Migration[5.0]
  def up
    begin
      CalculatedGiftField.rebuild_view!
    rescue StandardError => e
      puts "DATA MIGRATION FAILED in #{__FILE__}: #{e.message}"
    end
  end
end
