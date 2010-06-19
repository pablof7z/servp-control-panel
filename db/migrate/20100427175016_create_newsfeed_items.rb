class CreateNewsfeedItems < ActiveRecord::Migration
  def self.up
    create_table :newsfeed_items do |t|
      t.integer :user_id
      t.string :text
      t.integer :account_id
      t.integer :server_id
      t.integer :ticket_id

      t.timestamps
    end
  end

  def self.down
    drop_table :newsfeed_items
  end
end
