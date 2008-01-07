class CreateNewsletterSubscribers < ActiveRecord::Migration
  def self.up
    create_table :newsletter_subscribers do |t|
      t.column :name,             :string
      t.column :email,            :string
      t.column :newsletter_id,    :integer
      
      t.column :activation_code,  :string
      t.column :activated_at,     :datetime, :default => nil
      
      t.column :unsubscription_code, :string, :default => nil
      t.column :unsubscribed_at,  :datetime, :default => nil
      
      t.column :created_at,       :datetime
      t.column :updated_at,       :datetime
    end
  end

  def self.down
    drop_table :newsletter_subscribers
  end
end