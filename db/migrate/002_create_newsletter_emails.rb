class CreateNewsletterEmails < ActiveRecord::Migration
  def self.up
    create_table :newsletter_emails do |t|
      t.column :page_id,            :integer
      t.column :from,               :string
      t.column :to,                 :string
      t.column :last_send_attempt,  :integer, :default => 0
      t.column :mail,               :text
      t.column :created_on,         :datetime
    end
  end

  def self.down
    drop_table :newsletter_emails
  end
end