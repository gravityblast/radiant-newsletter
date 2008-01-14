class CreateNewsletterLogs < ActiveRecord::Migration
  def self.up
    create_table :newsletter_logs do |t|
      t.column :message_type,       :string
      t.column :message,            :text
      t.column :created_at,         :datetime
    end
  end

  def self.down
    drop_table :newsletter_logs
  end
end
