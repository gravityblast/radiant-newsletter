class NewsletterLogsController < ApplicationController

  def index    
    @logs = NewsletterLog.find(:all, :order => 'newsletter_logs.created_at DESC, newsletter_logs.id DESC ', :limit => 50)
  end
  
end
