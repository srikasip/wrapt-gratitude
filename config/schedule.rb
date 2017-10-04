# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, "/home/ubuntu/cron.log"

# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end

every 1.days, at: '2:00am', roles: :staging_cron do
  rake "db:clone_production"
end

every 4.days, roles: :cron do
  rake "letsencrypt_plugin"
end

# Learn more: http://github.com/javan/whenever
