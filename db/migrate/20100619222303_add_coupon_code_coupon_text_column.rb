class AddCouponCodeCouponTextColumn < ActiveRecord::Migration
  def self.up
  	add_column :coupon_codes, :description, :string, :null => false
  end

  def self.down
  	remove_column :coupon_codes, :description
  end
end
