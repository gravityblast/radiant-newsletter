require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
NewslettersController.class_eval { def rescue_action(e) raise e end }

class NewslettersControllerTest < Test::Unit::TestCase
  
  fixtures :pages, :page_parts, :users, :newsletter_subscribers
  test_helper :login
  
  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @controller = NewslettersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new    
    login_as :existing
  end

  def test_new_should_redirect_if_page_doeas_not_exist
    get :new, :page_id => 9999
    assert_response :redirect
  end
  
  def test_new_should_redirect_if_page_is_not_child_of_a_newsletter_page
    get :new, :page_id => pages(:homepage).id
    assert_response :redirect
  end
  
  def test_new_should_be_ok_if_page_is_child_of_a_newsletter_page
    get :new, :page_id => pages(:first_email_for_newsletter).id
    assert_response :success
  end
  
  def test_create_should_redirect_if_get?
    get :create
    assert_response :redirect
  end
  
  def test_create_should_redirect_if_page_doeas_not_exist
    post :create, :page_id => 9999
    assert_response :redirect
  end
  
  def test_create_should_redirect_if_page_is_not_child_of_a_newsletter_page
    post :create, :page_id => pages(:homepage).id
  end
  
  def test_create_should_send_emails_if_page_is_child_of_a_newsletter_page
    subscribers_count = pages(:newsletter).active_subscribers.count
    assert_difference NewsletterEmail, :count, subscribers_count * 2 do
      post :create, :page_id => pages(:first_email_for_newsletter).id
      assert_redirected_to :controller => '/admin/page', :action => 'edit', :id => pages(:first_email_for_newsletter).id      
      assert_equal subscribers_count, NewsletterEmail.count(:conditions => ["page_id = ?", pages(:first_email_for_newsletter).id])
      assert_equal pages(:first_email_for_newsletter), NewsletterEmail.find(:first).page
      assert_not_nil pages(:first_email_for_newsletter).reload.sent_as_newsletter_email_at
      
      post :create, :page_id => pages(:second_email_for_newsletter).id
      assert_redirected_to :controller => '/admin/page', :action => 'edit', :id => pages(:second_email_for_newsletter).id
      assert_equal subscribers_count, NewsletterEmail.count(:conditions => ["page_id = ?", pages(:second_email_for_newsletter).id])
      assert_equal pages(:second_email_for_newsletter), NewsletterEmail.find(:all).last.page
      assert_not_nil pages(:second_email_for_newsletter).reload.sent_as_newsletter_email_at
      assert_equal 0, ActionMailer::Base.deliveries.size
    end    
  end

  def test_create_should_send_emails_with_subscriber_if_page_is_a_newsletter_email_page
    post :create, :page_id => pages(:first_email_for_newsletter).id
    body = NewsletterEmail.find(:first).mail
    assert_match(%r{newsletters\/4\/track\/1\/click}, body) # Link
    assert_match(%r{newsletters\/4\/track\/1\/open}, body) # Web beacon    
  end
  
  def test_should_send_test_email
    assert_difference NewsletterEmail, :count, 0 do
      post :create, :test_email => 1, :address => 'test@example.com', :page_id => pages(:first_email_for_newsletter).id
      assert_redirected_to :controller => '/admin/page', :action => 'edit', :id => pages(:first_email_for_newsletter).id
      assert_equal 1, ActionMailer::Base.deliveries.size
      email = ActionMailer::Base.deliveries[0]
      assert_equal 1, email.header["to"].addrs.size
      assert_equal "test@example.com", email.header["to"].addrs[0].spec
    end
  end
  
  def test_should_not_send_test_email_unless_address
    assert_difference NewsletterEmail, :count, 0 do
      post :create, :test_email => 1, :page_id => pages(:first_email_for_newsletter).id
      assert_response :success
      assert_not_nil flash[:error]
      assert_equal 0, ActionMailer::Base.deliveries.size
    end
  end
  
end
