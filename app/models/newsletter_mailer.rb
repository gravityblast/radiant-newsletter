class NewsletterMailer < ActionMailer::Base

  def newsletter(subject, body, recipients, from, sent_at = Time.now)
    @subject      = subject
    @body         = body
    @recipients   = recipients
    @from         = from
    @sent_on      = sent_at
    @headers      = {}
    @content_type = 'text/html'
  end
end
