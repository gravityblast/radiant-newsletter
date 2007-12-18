require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
NewsletterController.class_eval { def rescue_action(e) raise e end }

class NewsletterControllerTest < Test::Unit::TestCase
  
  fixtures :pages, :page_parts, :users, :newsletter_subscribers
  test_helper :login
  
  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @controller = NewsletterController.new
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
    post :create, :page_id => pages(:first_email_for_newsletter).id
    assert_response :redirect, :controller => '/admin/page', :action => 'edit', :id => pages(:first_email_for_newsletter).id
    assert_equal 2, ActionMailer::Base.deliveries.size
    mail    = ActionMailer::Base.deliveries[0]
    mail_2  = ActionMailer::Base.deliveries[1]
    assert_equal "[#{pages(:first_email_for_newsletter).parent.config["subject_prefix"]}] #{pages(:first_email_for_newsletter).title}", mail.header["subject"].body
    assert_equal "Tom <tom@example.com>", mail.header["to"].body
    assert_equal "Mike <mike@example.com>", mail_2.header["to"].body
    assert_equal "Hello from the first newsletter", mail.body
  end
  
end
