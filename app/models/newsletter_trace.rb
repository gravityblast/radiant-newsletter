class NewsletterTrace < ActiveRecord::Base
  
  belongs_to :newsletter_email, :class_name => 'NewsletterEmailPage', :foreign_key => 'newsletter_email_page_id'
  belongs_to :subscriber, :class_name => 'NewsletterSubscriber', :foreign_key => 'newsletter_subscriber_id'
  
  validates_uniqueness_of :newsletter_subscriber_id, :scope => [:trace_type, :newsletter_email_page_id]
  
end
