class CreateSubscriptionPeriods < ActiveRecord::Migration
  def self.up
    create_table :subscription_periods do |t|
      t.datetime :start, :null => false
      t.datetime :end, :null => false
      t.integer :subscription_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :subscription_periods
  end
end
