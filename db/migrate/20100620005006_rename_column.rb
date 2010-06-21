class RenameColumn < ActiveRecord::Migration
  def self.up
  	rename_column :applied_coupons, :coupon_id, :coupon_code_id
  end

  def self.down
  	rename_column :applied_coupons, :coupon_code_id, :coupon_id
  end
end
