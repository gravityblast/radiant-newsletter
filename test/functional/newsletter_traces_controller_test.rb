require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
NewsletterTracesController.class_eval { def rescue_action(e) raise e end }

class NewsletterTracesControllerTest < Test::Unit::TestCase
  fixtures :pages, :newsletter_subscribers, :newsletter_traces
  
  def setup
    @controller = NewsletterTracesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @newsletter = pages(:first_email_for_newsletter)
  end

  def test_create_open
    subscriber = newsletter_subscribers(:james)
    opened_count =  @newsletter.opened_count
    get :open, { :id =>  @newsletter.id, :subscriber_id => subscriber.id }
    assert_response(:success)
    assert_equal 'image/gif', @response.content_type
    assert_equal opened_count + 1,  @newsletter.opened_count
  end
  
  def test_create_click
    subscriber = newsletter_subscribers(:mike)
    clicked_count =  @newsletter.clicked_count
    get :click, { :id =>  @newsletter.id, :subscriber_id => subscriber.id, :url => 'http://google.com' }
    assert_redirected_to 'http://google.com'
    assert_equal clicked_count + 1,  @newsletter.clicked_count    
  end

end
