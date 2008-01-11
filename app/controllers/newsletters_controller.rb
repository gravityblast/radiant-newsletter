class NewslettersController < ApplicationController

  before_filter :find_page_and_newsletter
  
  def new
  end
  
  def create
    if request.post?
      if params[:test_email]
        if params[:address] =~ /^$|^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
          send_test_email(@newsletter, @page, params[:address])
        else
          flash[:error] = "You must specify an email address"
          render :action => 'new' and return
        end
      else
        send_emails(@newsletter, @page)
      end
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
  
  def send_emails(newsletter, page)
    info = email_info(newsletter, page)
    newsletter.recipients.each do |address|      
      email = NewsletterMailer.create_newsletter(info[:subject], info[:html_body], address, info[:from])
      NewsletterEmail.create({
        :page_id        => page.id,
        :mail           => email.encoded, 
        :to             => address,
        :from           => info[:from]
      })
    end
    page.update_attribute(:sent_as_newsletter_email_at, Time.now)
  end     
  
  def send_test_email(newsletter, page, address)
    info = email_info(newsletter, page)
    email = NewsletterMailer.create_newsletter(info[:subject], info[:html_body], address, info[:from])    
    NewsletterMailer.deliver(email)
  end
    
  def email_info(newsletter, page)
    {
      :subject => "[#{newsletter.config["subject_prefix"]}] #{page.title}",
      :html_body => page.render,
      :from => newsletter.config["from"]
    }
  end
  
end
