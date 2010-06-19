class CreateTicketUpdates < ActiveRecord::Migration
  def self.up
    create_table :ticket_updates do |t|
      t.integer :ticket_id, :null => false
      t.integer :user_id, :null => false
      t.string :keyword, :null => false
      t.string :value
      t.string :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :ticket_updates
  end
end
