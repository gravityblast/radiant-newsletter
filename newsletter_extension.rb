# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class NewsletterExtension < Radiant::Extension
  version "0.1.5"
  description "Adds a newsletter system to RadiantCMS"
  url "http://gravityblast.com/projects/radiant-newsletter-extension/"
  
  define_routes do |map|
    map.connect 'admin/newsletters/logs/',                                    :controller => 'newsletter_logs'
    map.connect 'admin/newsletters/:newsletter_id/subscribers/:action/:id',   :controller => 'newsletter_subscribers'
    map.connect 'admin/newsletters/:newsletter_id/subscribers/:action/:id',   :controller => 'newsletter_subscribers'
    map.connect 'admin/newsletters/:page_id/:action',                         :controller => 'newsletters'    
    map.connect 'newsletters/:id/track/:subscriber_id/open',                  :controller => 'newsletter_traces', :action => 'open'    
    map.connect 'newsletters/:id/track/:subscriber_id/click',                 :controller => 'newsletter_traces', :action => 'click'
  end
  
  def activate
    Page.class_eval{ has_many :emails, :class_name => 'NewsletterEmail', :dependent => :delete_all }
    NewsletterPage
    NewsletterEmailPage
    admin.page.edit.add :main, "page_edit_main_newsletter", :after => 'edit_header'
  end
  
  def deactivate
    admin.tabs.remove "Newsletter"
  end
  
end