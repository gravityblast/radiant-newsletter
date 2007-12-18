class NewsletterSubscriber < ActiveRecord::Base
  
  attr_protected :activation_code, :unsubscription_code
  
  belongs_to :newsletter, :class_name => 'NewsletterPage', :foreign_key => 'newsletter_id'
  
  validates_presence_of :email

  #TODO: add validation to newsletter.Does the newsletter page exists?
  
  validates_format_of :email, :with => /^$|^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :if => Proc.new{|ns| !ns.email.blank? }
  
  before_create :generate_activation_code
  before_create :generate_unsubscription_code
  
  def validate
    if s = self.class.find(:first, :conditions => ["id != ? AND email = ? AND newsletter_id = ? AND unsubscribed_at IS ?", self.id.to_s, self.email, self.newsletter_id, nil])
      errors.add(:email, 'has already been taken')
    end    
  end
  
  class << self    
    def find_active_subscriber_by_newsletter_and_email(newsletter, email)
      find(:first, :conditions => ["activated_at IS NOT ? AND unsubscribed_at IS ? AND newsletter_id = ? AND email = ?", nil, nil, newsletter.id, email])
    end
    
    def find_active_subscriber_by_newsletter_and_unsubscription_code(newsletter, unsubscription_code)
      find(:first, :conditions => ["activated_at IS NOT ? AND unsubscribed_at IS ? AND newsletter_id = ? AND unsubscription_code = ?", nil, nil, newsletter.id, unsubscription_code])
    end     
    
    def find_active_subscribers
      find(:all, :conditions => ["activated_at IS NOT ? AND unsubscribed_at IS ?", nil, nil])
    end
    
    def count_active_subscribers
      count(:conditions => ["activated_at IS NOT ? AND unsubscribed_at IS ?", nil, nil])
    end
    
    def find_active_subscribers_by_newsletter(newsletter)
      find(:all, :conditions => ["activated_at IS NOT ? AND unsubscribed_at IS ? AND newsletter_id = ?", nil, nil, newsletter.id])
    end    
  end
  
  def activate
    self.activated_at = Time.now 
    self.activation_code = nil # I can't use update_attributes cause activation_code is protected
    save
  end
  
  def unsubscribe
    update_attribute(:unsubscribed_at, Time.now)
  end  
    
private

  def generate_activation_code
    self.activation_code = Digest::SHA1.hexdigest( "activation code #{self.email}-#{Time.now}".split(//).sort_by {rand}.join )    
  end
  
  def generate_unsubscription_code
    self.unsubscription_code = Digest::SHA1.hexdigest( "unsubscribe code #{self.email}-#{Time.now}".split(//).sort_by {rand}.join )    
  end
  
end
