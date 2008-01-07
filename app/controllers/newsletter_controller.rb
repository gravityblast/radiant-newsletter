class NewsletterController < ApplicationController

  before_filter :find_page_and_newsletter
  
  def new
  end
  
  def create
    if request.post?      
      send_mail(@newsletter, @page)
      flash[:notice] = "Newsletter has been sent correctly"
      redirect_to(:controller => '/admin/page', :action => 'edit', :id => @page)
    else
      redirect_to(:action => "new", :page_id => @page.id)
    end
  end
  
  def preview
    render :text => @page.render
  end

private
  
  def find_page_and_newsletter
    @page = Page.find(params[:page_id])
    @newsletter = @page.parent
    redirect_to('/admin/') and return if !@newsletter || @newsletter.class_name != 'NewsletterPage'
  rescue ActiveRecord::RecordNotFound  
    redirect_to('/admin')
  end
  
  def send_mail(newsletter, page)
    subject = "[#{newsletter.config["subject_prefix"]}] #{page.title}"
    html_body = page.render    
    from = newsletter.config["from"]    
    newsletter.recipients.each do |address|      
      mail = NewsletterMailer.create_newsletter(subject, html_body, address, from)
      NewsletterEmail.create({
        :page_id        => page.id,
        :mail           => mail.encoded, 
        :to             => address,
        :from           => from
      })
    end        
  end     
  
end
