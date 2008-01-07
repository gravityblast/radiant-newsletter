namespace :radiant do
  namespace :extensions do
    namespace :newsletter do
      namespace :email do
        
        desc "Sends mails with ar_mailer"
        task :send => :environment do
          ActionMailer::Base.logger = ActionController::Base.logger          
          m = ActionMailer::ARSendmail.new(:TableName => 'NewsletterEmail', :BatchSize => 20, :Once => true, :Verbose => true)
          m.run
        end
        
      end                        
    end
  end
end
