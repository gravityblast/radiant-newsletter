class NewsletterLog < ActiveRecord::Base
 
  before_create :parse_message
 
  class << self
    def info(message)
      create :message => message
    end
  end

protected

  def parse_message
    self.message.sub!(/^ar_sendmail:/, '').strip!
    case self.message
    when /^expired \d+/
      self.message_type = 'info'
    when /^server too busy/
      self.message_type = 'info'
    when /^authentication error/
      self.message_type = 'error'
    when /^caught signal, shutting down/
      self.message_type = 'error'
    when /^found \d+ emails to send/
      self.message_type = 'info'
    when /^sent email (\d+) from ([^\s]+) to ([^\s]+):/    
      self.message_type = 'info'
    when /^5xx error sending email (\d+), removing from queue:/    
      self.message_type = 'error'
    when /^error sending email (\d+):/
      self.message_type = 'error'
    end
  end
  
    
end
