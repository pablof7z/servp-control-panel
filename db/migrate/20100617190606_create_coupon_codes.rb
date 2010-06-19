class CreateCouponCodes < ActiveRecord::Migration
  def self.up
    create_table :coupon_codes do |t|
      t.string :code, :null => false
      t.date :not_before
      t.date :not_after
      t.integer :max_total, :null => false
      t.integer :max_account, :null => false, :default => 1
      t.integer :validity, :null => false
      t.string :affects, :null => false
      t.integer :amount, :null => false
      t.string :amount_unit, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :coupon_codes
  end
end
