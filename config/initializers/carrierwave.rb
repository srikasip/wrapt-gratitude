CarrierWave.configure do |config|
  config.fog_credentials = {
    provider:              'AWS',
    aws_access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
    aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    region:                'us-east-1',
    host:                  's3.amazonaws.com',
    endpoint:              'https://s3.amazonaws.com'
  }

  config.fog_directory  = ENV.fetch('BUCKET_NAME') { "wrapt-alternate" }
  config.fog_public     = false # defaults to true
  config.fog_attributes = { 'Cache-Control' => "max-age=#{365.day.to_i}" }
  config.fog_authenticated_url_expiration = 7.days.to_i
  config.max_file_size = 100.megabytes
end
