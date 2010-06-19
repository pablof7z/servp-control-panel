class CreateBmSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :bm_subscriptions do |t|
      t.integer :subscription_id, :null => false
      t.string :service_provider, :null => false, :default => 'unknown'

      t.timestamps
    end
  end

  def self.down
    drop_table :bm_subscriptions
  end
end
