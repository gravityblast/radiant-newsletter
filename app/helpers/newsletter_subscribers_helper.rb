module NewsletterSubscribersHelper
  def newsletter_subscriber_list_link_to(name, by)      
    options = {:by => by}
    if @list_options[:by].to_sym == by.to_sym
      options[:order] = @list_options[:order] == 'asc' ? 'desc' : 'asc'
    end
    link_to(name, @list_options.merge(options))
  end
  
end