require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
NewsletterSubscribersController.class_eval { def rescue_action(e) raise e end }

class NewsletterSubscribersControllerTest < Test::Unit::TestCase
  
  fixtures :pages, :users, :newsletter_subscribers
  test_helper :login
  
  def setup
    @controller = NewsletterSubscribersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :existing
  end

  def test_should_import_from_textarea
    count = pages(:newsletter).active_subscribers.count
    assert_difference NewsletterSubscriber, :count, 7 do
      File.open(File.dirname(__FILE__) + "/../fixtures/import/textarea") do |file|
        post :import, :newsletter_id => pages(:newsletter), :recipients => file.read
        assert_equal count + 7, pages(:newsletter).active_subscribers.count
      end
    end
    1.upto(8) do |i|; next if i == 7
      assert_not_nil pages(:newsletter).subscribers.find_by_email("email_#{i}@example.com")
    end
  end
end
