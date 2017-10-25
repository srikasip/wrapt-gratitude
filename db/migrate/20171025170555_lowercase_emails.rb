class LowercaseEmails < ActiveRecord::Migration[5.0]
  def change
    begin
      execute <<~SQL
        update users set email = lower(email) where email not in ( 'DBean@paragusit.com', 'katePermut@aol.com' );
      SQL
    rescue Exception => e
      puts "Data migration failed in #{__FILE__}: #{e.message}"
    end
  end
end
