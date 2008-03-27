require File.dirname(__FILE__) + '/../test_helper'

class NewsletterTraceTest < Test::Unit::TestCase
  fixtures :pages, :newsletter_subscribers, :newsletter_traces

  def setup
    @newsletter = pages(:first_email_for_newsletter)
  end
  
  def test_associations
    trace = newsletter_traces(:tom_opened_newsletter)
    assert_not_nil trace.newsletter_email
    assert_not_nil trace.subscriber
    assert_equal @newsletter.id, trace.newsletter_email.id
    assert_equal newsletter_subscribers(:tom).id, trace.subscriber.id
  end

  def test_newsletter_trace
    trace_count = @newsletter.traces.length
    assert_equal 3, trace_count
    assert @newsletter.traces.create( :trace_type => :click, :newsletter_subscriber_id => newsletter_subscribers(:mike).id, :trace_data => 'http://apple.com' )
    assert_equal trace_count + 1, @newsletter.traces.length
  end
  
  def test_uniqueness
    NewsletterTrace.destroy_all
    trace_attributes = { :trace_type => :open, :newsletter_subscriber_id => newsletter_subscribers(:tom).id, :newsletter_email_page_id => @newsletter.id }
    trace_count = NewsletterTrace.find(:all).length
    trace = NewsletterTrace.create( trace_attributes )
    assert_equal false, trace.new_record?
    assert trace.valid?
    assert_equal trace_count + 1, NewsletterTrace.find(:all).length
    trace = NewsletterTrace.create( trace_attributes )
    assert trace.new_record?
    assert_equal false, trace.valid?
    assert_equal trace_count + 1, NewsletterTrace.find(:all).length
  end


end