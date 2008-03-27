class CreateNewsletterTraces < ActiveRecord::Migration
  def self.up
    create_table :newsletter_traces do |t|
      t.column :newsletter_email_page_id, :integer
      t.column :newsletter_subscriber_id, :integer
      t.column :trace_type, :string
      t.column :trace_data, :text
      t.column :created_on, :datetime
    end
  end

  def self.down
    drop_table :newsletter_traces
  end
end
