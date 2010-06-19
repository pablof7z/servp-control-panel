class CreateAppliedCoupons < ActiveRecord::Migration
  def self.up
    create_table :applied_coupons do |t|
      t.integer :coupon_id, :null => false
      t.integer :account_id, :null => false
      t.datetime :start, :null => false
      t.datetime :finish, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :applied_coupons
  end
end
