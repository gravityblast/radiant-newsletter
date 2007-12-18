# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class NewsletterExtension < Radiant::Extension
  version "0.1.0"
  description "Adds a newsletter system to RadiantCMS"
  url "http://gravityblast.com/projects/radiant-newsletter-extension/"
  
  define_routes do |map|
    map.connect 'admin/newsletter/options/:action',   :controller => 'newsletter_options'
    map.connect 'admin/newsletter/:page_id/:action',  :controller => 'newsletter'
  end
  
  def activate
    NewsletterPage
    admin.tabs.add "Newsletter", "/admin/newsletter/options", :after => "Layouts", :visibility => [:all]
    admin.page.edit.add :main, "send_as_newsletter_button"
  end
  
  def deactivate
    admin.tabs.remove "Newsletter"
  end
  
end