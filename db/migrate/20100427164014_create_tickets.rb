class CreateTickets < ActiveRecord::Migration
  def self.up
    create_table :tickets do |t|
      t.string :ticket_type, :null => false
      t.string :mask, :null => false
      t.string :subject
      t.string :from
      t.string :reply_to
      t.string :cc
      t.string :text
      t.integer :created_by_id, :null => false
      t.string :status, :null => false, :default => 'New'
      t.string :assigned_to_id
      t.integer :account_id
      t.integer :server_id
      t.string :priority, :default => 'Normal'
      t.datetime :grabbed_on

      t.timestamps
    end
  end

  def self.down
    drop_table :tickets
  end
end
