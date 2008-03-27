require File.dirname(__FILE__) + '/../test_helper'

class NewsletterSubscriberTest < Test::Unit::TestCase
  fixtures :newsletter_subscribers, :pages

  def test_should_create_newsletter_subscriber
    assert_difference NewsletterSubscriber, :count do
      create_newsletter_subscriber
    end
  end
  
  def test_should_validate_presences_of_email
    assert_difference NewsletterSubscriber, :count, 0 do
      s = create_newsletter_subscriber(:email => nil)
      assert s.errors.on(:email)
    end
  end
  
  def test_should_validate_format_of_email
    assert_difference NewsletterSubscriber, :count, 0 do
      s = create_newsletter_subscriber(:email => "example.com")
      assert s.errors.on(:email)
    end
  end    
  
  def test_should_delete_activation_code_after_activation
    s = create_newsletter_subscriber
    assert_not_nil s.activation_code
    s.activate
    assert_nil s.activation_code
  end    
  
  def test_should_validate_presence_of_email
    assert_difference NewsletterSubscriber, :count, 0 do
      s = create_newsletter_subscriber(:email => nil)
      assert s.errors.on(:email)
    end
  end
  
  def test_should_validate_uniqueness_of_email_under_the_same_newsletter
    assert_difference NewsletterSubscriber, :count, 0 do
      s = create_newsletter_subscriber(:email => newsletter_subscribers(:tom).email, :newsletter => pages(:newsletter))
      assert s.errors.on(:email)
    end
    assert_difference NewsletterSubscriber, :count, 1 do
      s = create_newsletter_subscriber(:email => newsletter_subscribers(:tom).email, :newsletter => pages(:an_other_newsletter))
      assert_nil s.errors.on(:email)
    end
  end
  
  def test_should_be_validate_presence_of_newsletter_id
    assert_difference NewsletterSubscriber, :count, 0 do
      s = create_newsletter_subscriber(:email => newsletter_subscribers(:tom).email, :newsletter => nil)
      assert s.errors.on(:newsletter_id)
    end
  end
  
  def test_should_not_validate_uniqueness_of_email_under_an_other_newsletter
    assert_difference NewsletterSubscriber, :count do
      s = create_newsletter_subscriber(:email => "tom@example.com", :newsletter => pages(:an_other_newsletter))
      assert_nil s.errors.on(:email)
    end
  end
  
  def test_should_not_validate_uniqueness_of_email_if_existing_user_has_been_unsubscribed
    t = newsletter_subscribers(:tom)
    assert_nil t.unsubscribed_at
    t.unsubscribe
    assert_not_nil t.unsubscribed_at
    assert_difference NewsletterSubscriber, :count do
      s = create_newsletter_subscriber(:email => "tom@example.com")
      assert_nil s.errors.on(:email)
    end
    
  end
  
  def test_should_validate_format_of_email
    assert_difference NewsletterSubscriber, :count, 0 do
      s = create_newsletter_subscriber(:email => "example.com")
      assert s.errors.on(:email)
    end
  end
  
  def test_activation_code_should_be_protected
    assert_difference NewsletterSubscriber, :count do
      s = create_newsletter_subscriber(:email => "test@example.com")
      s.update_attributes(:activation_code => 'my_activation_code')
      assert_not_equal 'my_activation_code', s.activation_code
    end
  end
  
  def test_unsubscribe_code_should_be_protected
    assert_difference NewsletterSubscriber, :count do
      s = create_newsletter_subscriber(:email => "test@example.com")
      s.update_attributes(:unsubscription_code => 'my_unsubscription_code')
      assert_not_equal 'my_unsubscription_code', s.unsubscription_code
    end
  end
  
  def test_activted_at_should_be_protected
    assert_difference NewsletterSubscriber, :count do
      s = create_newsletter_subscriber(:email => "test@example.com")
      s.update_attributes(:activated_at => Time.now)
      assert_nil s.reload.activated_at
    end
  end

   def test_should_select_only_active_subscribers
    assert_equal 3, NewsletterSubscriber.find_active_subscribers.size
   end
      
   def test_should_select_only_active_subscribers_by_newsletter
     assert_equal 2, NewsletterSubscriber.find_active_subscribers_by_newsletter(pages(:newsletter)).size
     assert_equal 1, NewsletterSubscriber.find_active_subscribers_by_newsletter(pages(:an_other_newsletter)).size
   end
   
   def test_should_activate
     assert_difference NewsletterSubscriber, :count_active_subscribers do
       newsletter_subscribers(:paul).activate
     end
   end
   
   def test_should_activate
     assert_difference NewsletterSubscriber, :count_active_subscribers, -1 do
       newsletter_subscribers(:tom).unsubscribe
     end
   end
   
   def test_address
     assert_equal "Tom <tom@example.com>", newsletter_subscribers(:tom).address
   end
   
private

  def create_newsletter_subscriber(options = {})
    NewsletterSubscriber.create({:email => 'text@example.com', :newsletter => pages(:newsletter)}.merge(options))    
  end
  
end