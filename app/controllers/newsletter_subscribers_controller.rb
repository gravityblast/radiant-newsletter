class NewsletterSubscribersController < ApplicationController
  
  before_filter :find_newsletter
  before_filter :find_subscriber, :only => [:edit, :update, :destroy]

  def index
    @list_options         = {:by => 'created_at', :order => 'asc', :pp => 20}
    @list_options[:by]    = params[:by] if params[:by] && NewsletterSubscriber.columns.find{|column| column.name == params[:by]}
    @list_options[:order] = params[:order].to_s.downcase if ['desc', 'asc'].include?(params[:order].to_s.downcase)
    @list_options[:pp]    = params[:pp].to_i if params[:pp].to_i > 1
    @subscribers_pages, @subscribers = paginate(:newsletter_subscriber, :conditions => ["newsletter_id = ?", @newsletter.id], :per_page => @list_options[:pp], :order => "#{@list_options[:by]} #{@list_options[:order]}")
  end

  def new
    @subscriber = NewsletterSubscriber.new
  end

  def create
    @subscriber = NewsletterSubscriber.new(params[:subscriber])
    @subscriber.activated_at = Time.now
    if @subscriber.save
      flash[:notice] = 'Subscriber has been save correctly.'
      redirect_to :action => 'index'
    else
      flash[:error] = 'Validation errors occurred while processing this form. Please take a moment to review the form and correct any input errors before continuing.'
      render :action => 'new'
    end
  end

  def edit    
  end

  def update
      if @subscriber.update_attributes(params[:subscriber])
        flash[:notice] = 'Subscriber has been updated correctly.'
        redirect_to :action => 'index'
      else
        flash[:error] = 'Validation errors occurred while processing this form. Please take a moment to review the form and correct any input errors before continuing.'
        render :action => 'edit'
      end
  end

  def destroy
    @subscriber.destroy
    flash[:notice] = 'Subscriber has been deleted correctly.'
    redirect_to :action => 'index', :newsletter_id => @newsletter
  end

  private        
    
    def find_newsletter
      @newsletter = Page.find(params[:newsletter_id])
      redirect_to('/admin/') and return if @newsletter.class_name != 'NewsletterPage'
    rescue ActiveRecord::RecordNotFound  
      redirect_to('/admin')
    end
    
    def find_subscriber
      @subscriber = @newsletter.subscribers.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Subscriber not found"
      redirect_to(:action => 'index', :newsletter_id => @newsletter) and return 
    end
    
end