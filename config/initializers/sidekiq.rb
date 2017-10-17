Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL') { "redis://localhost:6379/0"} }
end

Sidekiq.configure_server do |config|
  # Uploaded images need to be processed faster than the default 15 second interval allows for.
  config.average_scheduled_poll_interval = 1
end

Sidekiq.default_worker_options = {'backtrace' => true}
