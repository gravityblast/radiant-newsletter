# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class NewsletterExtension < Radiant::Extension
  version "0.1.2"
  description "Adds a newsletter system to RadiantCMS"
  url "http://gravityblast.com/projects/radiant-newsletter-extension/"
  
  define_routes do |map|
    map.connect 'admin/newsletters/:newsletter_id/subscribers/:action/:id',   :controller => 'newsletter_subscribers'
    map.connect 'admin/newsletters/:page_id/:action',                         :controller => 'newsletters'    
  end
  
  def activate
    NewsletterPage
    Page.class_eval{ has_many :emails, :class_name => 'NewsletterEmail', :dependent => :delete_all }
    admin.page.edit.add :main, "page_edit_main_newsletter"
  end
  
  def deactivate
    admin.tabs.remove "Newsletter"
  end
  
end