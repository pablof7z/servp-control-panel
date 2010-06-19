class CreateAppliedCouponSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :applied_coupon_subscriptions do |t|
      t.integer :applied_coupon_id, :null => false
      t.integer :subscription_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :applied_coupon_subscriptions
  end
end
