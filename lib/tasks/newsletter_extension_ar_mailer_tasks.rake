namespace :radiant do
  namespace :extensions do
    namespace :newsletter do
      namespace :email do
        
        desc "Sends mails with ar_mailer"
        task :send => :environment do
          ActionMailer::Base.logger = NewsletterLog #ActionController::Base.logger          
          m = ActionMailer::ARSendmail.new(:TableName => 'NewsletterEmail', :BatchSize => 20, :Once => true, :Verbose => true, :MaxAge => 0)
          m.verbose = true
          m.run
        end
        
      end                        
    end
  end
end
