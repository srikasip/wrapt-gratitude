require 'shippo'

Shippo::API.token = ENV.fetch('SHIPPO_TOKEN') do
  raise 'You must set a shippo token in your .env.local file or otherwise set the SHIPPO_TOKEN environment variable.'
end
