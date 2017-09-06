module IsADatabaseView
  extend ActiveSupport::Concern

  module ClassMethods
    def rebuild_view!
      drop_view!
      connection.transaction do
        connection.execute(<<~SQL)
          CREATE VIEW #{@view_name} AS
          #{view_definition}
        SQL
      end
    end

    def drop_view!
      connection.transaction do
        connection.execute(<<~SQL)
          DROP VIEW IF EXISTS #{@view_name};
        SQL
      end
    end

    def view_name= name
      @view_name = name
    end

    def view_definition
      raise "You must specify definition in your view model"
    end
  end

  included do |klass|
    klass.view_name = klass.name.tableize
  end
end
