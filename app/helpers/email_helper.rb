module EmailHelper
  def email_image_url(path)
    fqdn        = ENV.fetch('APP_FQDN') { 'localhost' }
    port        = ENV.fetch('APP_PORT') { '3000' }
    port_string = port == '80' ? '' : ":#{port}"

    "https://#{fqdn}#{port_string}/email-signature-images/#{path}"
  end
end
