require 'yaml'

namespace :radiant do
  namespace :extensions do
    namespace :newsletter do
      namespace :page do
        
        desc "Creates a NewsletterPage with the default page parts"
        task :new => :environment do
          pages_fixture = File.join(NewsletterExtension.root, 'test', 'fixtures', 'pages.yml')
          page_parts_fixture = File.join(NewsletterExtension.root, 'test', 'fixtures', 'page_parts.yml')
          pages = YAML.load_file(pages_fixture)
          page_parts = YAML.load_file(page_parts_fixture)
          newsletter_page_attributes = pages["newsletter"]
          newsletter_page_attributes["parent_id"]  = ENV["PARENT_ID"] if ENV["PARENT_ID"]
          if ENV["TITLE"]
            newsletter_page_attributes["title"] = ENV["TITLE"]
          end
          if ENV["SLUG"]
            newsletter_page_attributes["slug"] = ENV["SLUG"]
          else
            newsletter_page_attributes["slug"] = newsletter_page_attributes["title"].downcase.gsub(/[^-a-z0-9~\s\.:;+=_]/, '').strip.gsub(/[\s\.:;=+]+/, '-')
          end
          if ENV["BREADCRUMB"]
            newsletter_page_attributes["breadcrumb"] = ENV["BREADCRUMB"]
          else
            newsletter_page_attributes["breadcrumb"] = newsletter_page_attributes["title"]
          end
          page = Page.new
          if page.update_attributes(newsletter_page_attributes)
            puts "Page has been created succesfully"
            puts "Creating page parts..."
            %w[
              newsletter_body newsletter_subscribe newsletter_subscribed
              newsletter_activate newsletter_activated newsletter_unsubscribe
              newsletter_unsubscribed newsletter_confirm_unsubscription 
              newsletter_activation_email newsletter_unsubscription_email newsletter_config
            ].each do |part_name|            
              print '.'
              page_part_attributes = page_parts[part_name]
              page_part_attributes["page_id"] = page.id
              page.parts.create(page_part_attributes)
            end
            puts;puts "Page parts have been created"
          else
            puts "There are some errors:"
            page.errors.each{|k, v| puts " * #{v}"}
          end
        end
        
      end            
    end
  end
end
