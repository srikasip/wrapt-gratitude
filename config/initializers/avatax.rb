# Admin Console URL: https://admin-development.avalara.net
# Developer Documentation: https://developer.avalara.com/
# https://github.com/avadev/AvaTax-REST-V2-Ruby-SDK
# Greenriver's fork on greenriver branch: https://github.com/yakloinsteak/AvaTax-REST-V2-Ruby-SDK.git

AvaTax.configure do |config|
  config.endpoint = ENV.fetch('AVATAX_ENDPOINT') { 'https://sandbox-rest.avatax.com' }
  config.username = ENV.fetch('AVATAX_USERNAME')
  config.password = ENV.fetch('AVATAX_PASSWORD')
end
