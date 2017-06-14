class TestMailer < ActionMailer::Base
  def ping(email)
    mail(
      :to => email,
      :from => 'nobody@wrapt.com',
      :subject => "Test from wrapt",
      :body => "test",
      :content_type => "text/plain"
    )
  end
end
