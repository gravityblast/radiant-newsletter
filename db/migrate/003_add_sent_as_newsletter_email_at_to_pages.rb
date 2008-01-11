class AddSentAsNewsletterEmailAtToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :sent_as_newsletter_email_at, :datetime
  end

  def self.down
    remove_column :pages, :sent_as_newsletter_email_at    
  end
end