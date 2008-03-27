class NewsletterTracesController < ApplicationController
  no_login_required
  before_filter :find_newsletter_and_subscriber

  def open
    @newsletter.track_opened_by(@subscriber)
    image = File.read(File.join( NewsletterExtension.root, "lib/assets/", "transparent.gif"))
    render :text => image, :status => 200, :content_type => 'image/gif'    
  end
  
  def click
    url = params[:url]
    @newsletter.track_clicked_by(@subscriber, url)
    redirect_to url
  end
  
  private
  
    def find_newsletter_and_subscriber
      @newsletter = Page.find(params[:id])
      @subscriber = NewsletterSubscriber.find(params[:subscriber_id])
    end
  
end
