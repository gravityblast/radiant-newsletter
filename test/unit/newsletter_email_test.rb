require File.dirname(__FILE__) + '/../test_helper'

class NewsletterEmailTest < Test::Unit::TestCase
  fixtures :newsletter_emails, :pages
  
  def test_should_delete_all_emails_not_sent_yet_before_deleting_a_mail_page
    assert_equal 0, pages(:first_email_for_newsletter).emails.count
    10.times{|e| NewsletterEmail.create(:page_id => pages(:first_email_for_newsletter).id)}
    assert_equal 10, pages(:first_email_for_newsletter).emails.count
    assert_difference NewsletterEmail, :count, -10 do
      pages(:first_email_for_newsletter).destroy
    end    
  end
  
  def test_should_delete_all_emails_not_sent_yet_before_deleting_a_newsletter
    assert_equal 0, pages(:first_email_for_newsletter).emails.count
    10.times{|e| NewsletterEmail.create(:page_id => pages(:first_email_for_newsletter).id)}
    assert_equal 10, pages(:first_email_for_newsletter).emails.count
    assert_difference NewsletterEmail, :count, -10 do
      pages(:newsletter).destroy
    end    
  end
  
end