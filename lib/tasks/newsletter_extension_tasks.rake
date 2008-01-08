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
      
      desc "Launches update and migrate tasks"
      task :install => [:migrate, :update] do
      end            
            
    end
  end
end
