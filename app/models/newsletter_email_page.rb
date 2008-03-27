class NewsletterEmailPage < Page
  
  has_many :traces,
    :class_name => "NewsletterTrace",
    :foreign_key => "newsletter_email_page_id",
    :dependent => :delete_all

  has_many :subscribers,
    :finder_sql => 'select * from newsletter_subscribers where newsletter_id = #{parent_id}',
    :class_name => "NewsletterSubscriber"

    
  has_many :opened_subscribers,
    :through => :traces,
    :source => :subscriber,
    :class_name => "NewsletterSubscriber",
    :foreign_key => 'newsletter_email_page_id',
    :conditions => ["trace_type = 'open'"]
    
  has_many :clicked_subscribers,
    :through => :traces,
    :source => :subscriber,
    :class_name => "NewsletterSubscriber",
    :foreign_key => 'newsletter_email_page_id',
    :conditions => ["trace_type = 'click'"]

  # Page hooks
  def render_with_subscriber(subscriber)
    lazy_initialize_parser_and_context
    @context.globals.subscriber = subscriber
    render
  end  
  
  # Tracing helper methods
  
  def opened_count
    NewsletterTrace.count(:conditions => ['trace_type = ? AND newsletter_email_page_id = ?', 'open', self.id])
  end

  def clicked_count
    NewsletterTrace.count(:conditions => ['trace_type = ? AND newsletter_email_page_id = ?', 'click', self.id])
  end

  def clicked_urls
    traces.find(:all, :conditions => "trace_type = 'click'", :group => 'trace_data', :select => 'trace_data, count(trace_data) as count' )
  end

  def track_opened_by(subscriber)
    traces.create( :trace_type => 'open', :newsletter_subscriber_id => subscriber.id )
  end

  def track_clicked_by(subscriber, url)
    traces.create( :trace_type => 'click', :newsletter_subscriber_id => subscriber.id, :trace_data => url )
  end
  
  # Tags
  
  include Radiant::Taggable

  class TagError < StandardError; end

  tag 'newsletter' do |tag|
    tag.expand
  end

  tag 'newsletter:subscriber' do |tag|
    tag.expand if tag.globals.subscriber
  end

  desc %{
    Inserts the name of the subscriber into the newsletter

    *Usage*:

    <pre><code><r:newsletter:subscriber:name /></code></pre>
  }
  tag 'newsletter:subscriber:name' do |tag|
    tag.globals.subscriber.name
  end

  desc %{
    Inserts the email of the subscriber into the newsletter

    *Usage*:

    <pre><code><r:newsletter:subscriber:email /></code></pre>
  }
  tag 'newsletter:subscriber:email' do |tag|
    tag.globals.subscriber.email
  end

  tag 'newsletter:tracking' do |tag|
    tag.expand if tag.globals.subscriber
  end

  desc %{
    Inserts a tracking bug or web beacon in the newsletter, making you able to track how many users has opened the newsletter

    *Usage* (insert anywhere in the newsletter):

    <pre><code><r:newsletter:tracking:bug /></code></pre>
  }
  tag 'newsletter:tracking:bug' do |tag|
    "<img src=\"#{tag.globals.page.parent.config["base_url"]}/newsletters/#{tag.globals.page.id}/track/#{tag.globals.subscriber.id}/open\" />"
  end

  desc %{
    Inserts a trackable link into a newsletter, redirecting the user unnoticeably past our site each the link is clicked

    *Usage*:

    <pre><code><r:newsletter:tracking:link url="[url]">[Text or code to be wrapped in a link]</r:newsletter:tracking:link></code></pre>
  }
  tag 'newsletter:tracking:link' do |tag|
    raise TagError, "'url' attribute required" unless url = tag.attr['url']
    "<a href=\"#{tag.globals.page.parent.config["base_url"]}/newsletters/#{tag.globals.page.id}/track/#{tag.globals.subscriber.id}/click?url=#{CGI::escape(url)}\">#{tag.expand}</a>"
  end  
  
end