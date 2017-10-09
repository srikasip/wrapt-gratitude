class StagingEmailInterceptor
  WHITELISTED_EMAILS = ENV['WHITELISTED_EMAILS'].to_s.split(':')
  DOMAIN             = ENV.fetch('SMTP_DOMAIN') { 'example.com' }

  def self.delivering_email(message)
    message.to  = (filter(message.to) + ["noreply@#{DOMAIN}"])
    message.bcc = filter(message.bcc)
    message.cc  = filter(message.cc)
  end

  def self.filter(addresses)
    Array.wrap(addresses).select do |address|
      address.match(/greenriver\.(org|com)/) || address.in?(WHITELISTED_EMAILS)
    end
  end
end
