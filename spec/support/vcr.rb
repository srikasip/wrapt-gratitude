VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :excon
  config.hook_into :webmock
  config.hook_into :faraday
end
