module EmailHelper
  def email_image_url(path)
    fqdn        = ENV.fetch('APP_FQDN') { 'www.wrapt.com' }
    port        = ENV.fetch('APP_PORT') { '80' }
    port_string = port == '80' ? '' : ":#{port}"
    scheme      = ENV.fetch('APP_SCHEME') { 'https' }

    "#{scheme}://#{fqdn}#{port_string}/email-signature-images/#{path}"
  end
end
