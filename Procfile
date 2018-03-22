web: bin/rails server -p 3000 -b 0.0.0.0
worker: bundle exec sidekiq -q default -q mailers
web: bundle exec puma -C config/puma.rb
