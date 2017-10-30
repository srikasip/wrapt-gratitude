class AdminMailer < ApplicationMailer
  default({
    to: ENV['ADMIN_EMAILS'].to_s.split(/;/),
    from: 'nobody@wrapt.com'
  })

  def api_error(model_class:,model_id:,message:)
    body = <<~EOM
      There was an error with #{model_class} of id #{model_id}.
      Fetch it with m=#{model_class}.find(#{model_id}) in a console.
      Error message was:
      #{message}
    EOM

    mail({
      subject: "There was an API error on #{Rails.env}",
      body: body,
      content_type: "text/plain"
    })
  end
end
