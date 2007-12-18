require File.dirname(__FILE__) + '/../test_helper'
require 'site_controller'

# Re-raise errors caught by the controller.
SiteController.class_eval { def rescue_action(e) raise e end }

class NewsletterPageControllerTest < Test::Unit::TestCase

  fixtures :pages, :page_parts, :newsletter_subscribers
  test_helper :pages
  
  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @controller = SiteController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_should_render_public_newsletter_action
    NewsletterPage::ACTIONS[:public].each do |newsletter_action|
      get :show_page, :url => "newsletter/#{newsletter_action}"
      assert_response :success
    end
  end
  
  def test_should_not_render_private_newsletter_action
    NewsletterPage::ACTIONS[:private].each do |newsletter_action|
      get :show_page, :url => "newsletter/#{newsletter_action}"
      assert_response :missing
    end
  end
  
  def test_should_render_the_body_part
    get :show_page, :url => 'newsletter'
    assert_response :success
    assert_equal 'This is the newsletter page', @response.body.strip
  end
  
  def test_should_render_the_subscribe_part
    get :show_page, :url => 'newsletter/subscribe'
    assert_response :success
    assert_equal pages(:newsletter).render_part(:subscribe).strip, @response.body.strip
  end
  
  def test_should_render_the_subscribe_part_unless_validates_form
    error_message_code = "All fields are required"
    form_code = "<form action=\"/newsletter/subscribe/\" method=\"post\"><input type=\"text\" name=\"newsletter_subscriber[email]\" /><input type=\"submit\" value=\"Join\"/></form>"
    post :show_page, :url => 'newsletter/subscribe'
    assert_response :success
    assert_equal "#{error_message_code}\n\n#{form_code}", @response.body.strip
    post :show_page, :url => 'newsletter/subscribe', :newsletter_subscriber => {:email => 'example.com'}
    assert_response :success
    assert_equal "#{error_message_code}\n\n#{form_code}", @response.body.strip
    assert_equal 0, ActionMailer::Base.deliveries.size
  end
  
  def test_should_render_the_subscribed_part_if_newsletter_subscriber_email
    assert_difference NewsletterSubscriber, :count do
      post :show_page, :url => 'newsletter/subscribe', :newsletter_subscriber => {:email => 'test@example.com', :name => 'Pippo de pippus'}
      assert_response :success
      assert_equal pages(:newsletter).render_part(:subscribed).strip, @response.body.strip
      assert_equal 1, ActionMailer::Base.deliveries.size
      
      email = ActionMailer::Base.deliveries[0]
      assert_equal 1, email.header["to"].addrs.size
      assert_equal "test@example.com", email.header["to"].addrs[0].spec
      assert_equal "hello@example.com", email.header["from"].body
      assert_equal "[#{pages(:newsletter).config["subject_prefix"]}] Activation", email.header["subject"].body
      assert_match /click the following url to activate your subscription/, email.body
    end
  end
  
  def test_should_activate_newsletter_subscriber
    assert_difference NewsletterSubscriber, :count_active_subscribers do
      get :show_page, :url => "newsletter/activate/#{newsletter_subscribers(:paul).activation_code}"
      assert_response :success
      assert_equal 'You have been activated', @response.body.strip
    end
  end
  
  def test_should_not_activate_newsletter_subscriber_if_exists_but_not_in_this_newsletter
    assert_difference NewsletterSubscriber, :count_active_subscribers, 0 do
      get :show_page, :url => "newsletter/activate/#{newsletter_subscribers(:andy).activation_code}"
      assert_response :success
      assert_equal 'Activation code not found', @response.body.strip
    end
    assert_difference NewsletterSubscriber, :count_active_subscribers do
      get :show_page, :url => "an_other_newsletter/activate/#{newsletter_subscribers(:andy).activation_code}"
      assert_response :success
    end
  end
  
  def test_should_render_activate_action_if_subscriber_not_found
    assert_difference NewsletterSubscriber, :count_active_subscribers, 0 do
      get :show_page, :url => "newsletter/activate/#{'a' * 40}"
      assert_response :success
      assert_equal 'Activation code not found', @response.body.strip
    end
  end
  
  def test_should_render_unsubscribe_part    
    get :show_page, :url => 'newsletter/unsubscribe'
    assert_response :success
    assert_equal "#{unsubscribe_form_html_code}", @response.body.strip    
  end
  
  def test_should_render_unsubscribe_part_if_subscriber_not_found    
    post :show_page, :url => 'newsletter/unsubscribe', :newsletter_subscriber => {:email => 'ciao@example.com'}
    assert_response :success
    assert_equal "Sorry, there is no active subscriber with that email address\n\n#{unsubscribe_form_html_code}", @response.body.strip
  end
  
  def test_should_render_unsubscribe_part_if_subscriber_is_found_but_under_an_other_newsletter
    post :show_page, :url => 'newsletter/unsubscribe', :newsletter_subscriber => {:email => newsletter_subscribers(:rob).email }
    assert_response :success
    assert_equal "Sorry, there is no active subscriber with that email address\n\n#{unsubscribe_form_html_code}", @response.body.strip
  end
  
  def test_should_render_unsubscribed_part_if_subscriber_is_found    
    page_parts(:newsletter_config).update_attribute("content", "from: hello@example.com\nsubject_prefix: The new subject prefix")
    post :show_page, :url => 'newsletter/unsubscribe', :newsletter_subscriber => {:email => newsletter_subscribers(:tom).email}
    assert_response :success
    assert_equal "You will receive an email with your unsubscription code", @response.body.strip
    assert_equal 1, ActionMailer::Base.deliveries.size
    
    email = ActionMailer::Base.deliveries[0]
    assert_equal 1, email.header["to"].addrs.size
    assert_equal "tom@example.com", email.header["to"].addrs[0].spec
    assert_equal "hello@example.com", email.header["from"].body
    assert_equal "[#{pages(:newsletter).config["subject_prefix"]}] Confirm unsubscription", email.header["subject"].body
    assert_match /click the following url to unsubscribe/, email.body
  end
  
  def test_should_render_confirm_unsubscription_if_code_is_found
    post :show_page, :url => 'newsletter/unsubscribe', :newsletter_subscriber => {:email => newsletter_subscribers(:tom).email}
    assert_response :success
    assert_equal "You will receive an email with your unsubscription code", @response.body.strip
  end
  
  def test_should_render_confirm_unsubscription_if_subscriber_is_found
    get :show_page, :url => "newsletter/confirm_unsubscription/#{newsletter_subscribers(:tom).unsubscription_code}"
    assert_response :success
    assert_equal "You have been unsubscribed", @response.body.strip
  end
  
  def test_should_render_unsubscribe_if_subscriber_is_not_found
    get :show_page, :url => "newsletter/confirm_unsubscription/#{'a' * 40}"
    assert_response :success
    assert_equal "Sorry, there is no active subscriber with that email address\n\n#{unsubscribe_form_html_code}", @response.body.strip
  end
  
  def test_should_render_unsubscribe_if_subscriber_exists_but_under_another_newsletter
    get :show_page, :url => "newsletter/confirm_unsubscription/#{newsletter_subscribers(:rob).unsubscription_code}"
    assert_response :success
    assert_equal "Sorry, there is no active subscriber with that email address\n\n#{unsubscribe_form_html_code}", @response.body.strip
  end

private

  def unsubscribe_form_html_code
    "<form action=\"/newsletter/unsubscribe/\" method=\"post\"><input type=\"text\" name=\"newsletter_subscriber[email]\" /><input type=\"submit\" value=\"Join\"/></form>"
  end
  
end
