require File.dirname(__FILE__) + '/../test_helper'

class NewsletterPageTest < Test::Unit::TestCase
  fixtures :newsletter_subscribers, :pages, :page_parts
  
  def test_should_destroy_newsletter_subscriber
    assert_difference NewsletterSubscriber, :count, -4 do
      pages(:newsletter).destroy
    end    
  end
  
  def test_association
    assert_equal 4, pages(:newsletter).subscribers.size
    assert_equal 2, pages(:newsletter).active_subscribers.size
    assert_equal "Tom", pages(:newsletter).active_subscribers[0].name
    assert_equal 1, pages(:newsletter).unsubscribeds.size
    assert_equal "James", pages(:newsletter).unsubscribeds[0].name
  end   
  
  def test_recipients
    recipients = [ "Tom <tom@example.com>", "Mike <mike@example.com>" ]
    assert_equal recipients, pages(:newsletter).recipients
  end
  
  def test_config
    assert_equal "hello@example.com", pages(:newsletter).config["from"]
    page_parts(:newsletter_config).update_attribute("content", "")
    assert_equal "no-reply@example.com", pages(:newsletter).config["from"]
    page_parts(:newsletter_config).update_attribute("content", "from: yo@example.com")
    assert_equal "yo@example.com", pages(:newsletter).config["from"]
    assert_equal pages(:newsletter).title, pages(:newsletter).config["subject_prefix"]
    page_parts(:newsletter_config).update_attribute("content", "subject_prefix: This is the subject prefix")
    assert_equal "This is the subject prefix", pages(:newsletter).config["subject_prefix"]
  end
  
end