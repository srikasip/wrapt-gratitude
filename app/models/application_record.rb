class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.truncate cascade=false
    modifier = cascade ? 'CASCADE' : 'RESTRICT'
    connection.execute("TRUNCATE TABLE #{table_name} #{modifier}")
  end
end
