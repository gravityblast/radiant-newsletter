require 'yaml'

namespace :radiant do
  namespace :extensions do
    namespace :newsletter do
      
      desc "Runs the migration of the Newsletter extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          NewsletterExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          NewsletterExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Newsletter to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[NewsletterExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(NewsletterExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
      
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
