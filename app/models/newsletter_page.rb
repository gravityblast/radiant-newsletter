class NewsletterPage < Page
  
  has_many :subscribers,
    :class_name => "NewsletterSubscriber",
    :foreign_key => 'newsletter_id',
    :dependent => :delete_all
    
  has_many :active_subscribers,
    :class_name => "NewsletterSubscriber",
    :foreign_key => 'newsletter_id',
    :dependent => :delete_all,
    :conditions => ["activated_at IS NOT ? AND unsubscribed_at IS ?", nil, nil]

  has_many :unsubscribeds,
    :class_name => "NewsletterSubscriber",
    :foreign_key => 'newsletter_id',
    :dependent => :delete_all,
    :conditions => ["activated_at IS NOT ? AND unsubscribed_at IS NOT ?", nil, nil]
  
  ACTIONS = {
    :public => %w[ subscribe activate unsubscribe confirm_unsubscription ],
    :private => %w[ subscribed activated unsubscribed ]
  }
  
  def config
    default_config = {
      "from" => "no-reply@example.com",
      "subject_prefix" => self.title
    }
    string = render_part(:config)
    unless string.empty?
      hash = YAML::load(string)
      default_config.merge(hash)
    else
      default_config
    end
  end
  
  def recipients
    self.active_subscribers.collect{|s| "#{s.name} <#{s.email}>".gsub(/\s+/, ' ').strip }
  end
  
  def process(request, response)
    @request, @response = request, response
    if request.post?
      if @newsletter_action == 'subscribe'
        @newsletter_subscriber = NewsletterSubscriber.new
        if @newsletter_subscriber.update_attributes((request.parameters[:newsletter_subscriber] || {}).merge({:newsletter_id => self.id}))
          @newsletter_action = 'subscribed'
          send_activation_email(@newsletter_subscriber)
        else
          @newsletter_form_errors = true
        end
      elsif @newsletter_action == 'unsubscribe'
        @newsletter_subscriber = NewsletterSubscriber.find_active_subscriber_by_newsletter_and_email(self, request.parameters[:newsletter_subscriber][:email])
        if @newsletter_subscriber
          @newsletter_action = 'unsubscribed'
          send_unsubscription_email(@newsletter_subscriber)
        else
          @newsletter_form_errors = true
        end
      end      
    else # request.get?
      if @newsletter_action == 'activate'
        newsletter_subscriber = NewsletterSubscriber.find_by_activation_code_and_newsletter_id(@code, self.id)
        if newsletter_subscriber && newsletter_subscriber.activate
          @newsletter_subscriber_has_been_activated = true
          @newsletter_action = 'activated'
        end
      elsif @newsletter_action == 'confirm_unsubscription'
        @newsletter_subscriber = NewsletterSubscriber.find_active_subscriber_by_newsletter_and_unsubscription_code(self, @code)
        if @newsletter_subscriber
          @newsletter_subscriber.unsubscribe
        else
          @newsletter_action = 'unsubscribe'
          @newsletter_form_errors = true
        end
      end
    end
    super(request, response)
  end
  
  def find_by_url(url, live = true, clean = false)
    url = clean_url(url) if clean        
    if url =~ /^#{self.url}(#{ACTIONS[:public].join("|")})\/([a-zA-Z0-9]{40,})?\/?$/
      @newsletter_action = $1      
      @code = $2
      self
    else
      super
    end
  end
  
  def cache?
    false    
  end

  tag 'newsletter' do |tag|
    tag.expand
  end
  
  tag 'newsletter:unless_actions' do |tag|
    tag.expand unless (ACTIONS[:private] + ACTIONS[:public]).include?(@newsletter_action)
  end
  
  tag 'newsletter:if_actions' do |tag|
    tag.expand if (ACTIONS[:private] + ACTIONS[:public]).include?(@newsletter_action)
  end
  
  tag 'newsletter:if_form_errors' do |tag|
    tag.expand if @newsletter_form_errors
  end
   
  tag 'newsletter:unless_action' do |tag|
    action_name = tag.attr['name']
    tag.expand unless action_name == @newsletter_action
  end
  
  tag 'newsletter:if_action' do |tag|
    action_name = tag.attr['name']
    tag.expand if action_name == @newsletter_action
  end
  
  tag 'newsletter:subscriber' do |tag|
    tag.locals.newsletter_subscriber = @newsletter_subscriber
    tag.expand
  end
  
  tag 'newsletter:subscriber:name' do |tag|
    tag.locals.newsletter_subscriber.name if tag.locals.newsletter_subscriber
  end
  
  tag 'newsletter:subscriber:activation_code' do |tag|
    tag.locals.newsletter_subscriber.activation_code if tag.locals.newsletter_subscriber
  end
  
  tag 'newsletter:subscriber:unsubscription_code' do |tag|
    tag.locals.newsletter_subscriber.unsubscription_code if tag.locals.newsletter_subscriber
  end


private
  
  def send_activation_email(newsletter_subscriber)
    email = build_system_email(newsletter_subscriber, :activation)
    NewsletterMailer.deliver(email)    
  end
   
  def send_unsubscription_email(newsletter_subscriber) 
    email = build_system_email(newsletter_subscriber, :unsubscription)
    NewsletterMailer.deliver(email)    
  end
  
  def build_system_email(newsletter_subscriber, mail_action)
    html_body = case mail_action
    when :activation      then render_part(:activation_email)
    when :unsubscription  then render_part(:unsubscription_email)
    end
    subject = case mail_action
      when :activation      then "[#{self.config["subject_prefix"]}] Activation"
      when :unsubscription  then "[#{self.config["subject_prefix"]}] Confirm unsubscription"
    end
    recipients = [newsletter_subscriber.email]
    from = config["from"]
    NewsletterMailer.create_newsletter(subject, html_body, recipients, from)    
  end
  
end