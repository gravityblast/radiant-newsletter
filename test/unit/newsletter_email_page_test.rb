require File.dirname(__FILE__) + '/../test_helper'

class NewsletterEmailPageTest < Test::Unit::TestCase
  fixtures :newsletter_subscribers, :pages, :page_parts, :newsletter_traces
  
  def setup
    @newsletter = pages(:first_email_for_newsletter)  
  end
  
  def test_associations
    assert_not_nil @newsletter.subscribers
    assert_equal @newsletter.parent.subscribers.length, @newsletter.subscribers.length
    assert_not_nil @newsletter.opened_subscribers
    assert_equal 2, @newsletter.opened_subscribers.length
    assert_not_nil @newsletter.opened_subscribers
    assert_equal 1, @newsletter.clicked_subscribers.length
  end
  
  def test_trace_stats
    assert_equal 3, @newsletter.traces.length
    assert_equal 2, @newsletter.opened_count
    assert_equal 1, @newsletter.clicked_count
    assert_equal 1, @newsletter.clicked_urls.length
    assert_equal 1, @newsletter.clicked_urls.first.count.to_i
    assert_equal 'http://google.com', @newsletter.clicked_urls.first.trace_data
  end
  
  def test_tracing
    assert_equal 3, @newsletter.traces.length
    assert @newsletter.track_opened_by(newsletter_subscribers(:james))
    assert_equal 3, @newsletter.opened_count
    assert @newsletter.track_clicked_by(newsletter_subscribers(:mike), "http://google.com")
    assert_equal 2, @newsletter.clicked_count
    assert_equal 2, @newsletter.clicked_urls.find { |t| t.trace_data == "http://google.com" }.count.to_i
  end
  
  def test_render_with_subscriber
    body = @newsletter.render_with_subscriber(newsletter_subscribers(:tom))
    assert_not_nil body
    assert_match(%r{newsletters\/4\/track\/1\/click}, body) # Link
    assert_match(%r{newsletters\/4\/track\/1\/open}, body) # Web beacon    
  end

  def test_render
    body = @newsletter.render
    assert_not_nil body    
  end
  
end