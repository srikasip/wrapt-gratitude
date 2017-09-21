namespace :db do
  desc "Copy production to staging and run migrations"
  task :clone_production => [:environment, 'db:prod_dump', 'db:my_load', 'db:migrate_etc', 'db:sync_s3']

  task :prod_dump do
    raise "Nope" if Rails.env.production?

    db_password  = ENV.fetch('PRODUCTION_DB_PASSWORD')
    pg_dump_path = ENV.fetch('PG_DUMP_PATH')           { '/usr/lib/postgresql/9.5/bin/pg_dump' }
    db_host      = ENV.fetch('PRODUCTION_DB_HOST')
    db_name      = ENV.fetch('PRODUCTION_DB_NAME')     { 'wrapt_production' }
    db_user      = ENV.fetch('PRODUCTION_DB_USER')     { 'wrapt' }
    @dump_path    = ENV.fetch('DUMP_PATH')              { '/tmp/wrapt.sql' }

    puts "Make sure your ~/.pgpass file has a `#{db_host}:5432:#{db_name}:#{db_user}:#{db_password}` entry or equivalent and is chmod 0600"

    cmd = "#{pg_dump_path} --host=#{db_host} --dbname=#{db_name} --user=#{db_user} -w --file=#{@dump_path} --clean --if-exists"
    puts "Running: `#{cmd}`"
    system(cmd)

    cmd = "sed -e 's/DROP TABLE \\(..*\\);/DROP TABLE \\1 CASCADE;/' #{@dump_path} | grep -v 'OWNER TO' > #{@dump_path}.filt"
    puts "Running: `#{cmd}`"
    system(cmd)
  end

  task :my_load do
    if ENV['ALLOW_CLONE_PRODUCTION'] != 'true'
      raise "You can't clone production unless you've set ALLOW_CLONE_PRODUCTION to true"
    end

    raise "Nope" if Rails.env.production?

    puts "Removing all tables or else new tables on staging will cause migration failures on subsequent migrations"
    ActiveRecord::Base.connection.tables.each do |table_name|
      ActiveRecord::Base.connection.execute("drop table #{table_name} CASCADE")
    end
    ActiveRecord::Base.connection.execute("drop sequence internal_order_numbers")

    psql_path  = ENV.fetch('PSQL_PATH')               { '/usr/lib/postgresql/9.5/bin/psql' }
    db_config  = ActiveRecord::Base.connection_config
    my_db_host = db_config[:host] || 'localhost'
    my_db_name = ENV.fetch('RESTORE_DB_NAME')         { db_config[:database] || raise("Must have database name") }
    my_db_user = ENV.fetch('RESTORE_DB_USER') { db_config[:user] || 'root' }
    host_clause = ENV['RESTORE_NO_HOST']=='true' ? '' : "--host=#{my_db_host}"


    cmd = "#{psql_path} #{host_clause} --dbname=#{my_db_name} --username=#{my_db_user} -w --file=#{@dump_path}.filt"
    puts "Running: `#{cmd}`"
    system(cmd)
  end

  task :migrate_etc do
    puts "Running migrations."
    cmd = 'bundle exec rake db:migrate'
    puts "Running `#{cmd}`"
    system(cmd)

    cmd = 'touch tmp/restart.txt'
    puts "Running `#{cmd}`"
    system(cmd)
  end

  task :sync_s3 do
    raise "Nope" if Rails.env.production?

    environment_to_go_to = Rails.env.staging? ? 'staging' : 'development'
    cmd = "aws s3 sync --profile wrapt s3://wrapt-gratitude-production/ s3://wrapt-gratitude-#{environment_to_go_to}/"
    puts "Running `#{cmd}`"
    system(cmd)
  end
end
