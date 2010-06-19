class CreateBmSubscriptionPeriods < ActiveRecord::Migration
  def self.up
    create_table :bm_subscription_periods do |t|
      t.integer :subscription_period_id, :null => false
      t.integer :total_cats, :null => false
      t.integer :used_cats, :null => false, :default => 0
      t.integer :additional_cat_price_cents
      t.integer :guaranteed_response_time

      t.timestamps
    end
  end

  def self.down
    drop_table :bm_subscription_periods
  end
end
