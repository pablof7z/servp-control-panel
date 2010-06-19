class ChangeColumnBilling < ActiveRecord::Migration
  def self.up
  	change_column :subscriptions, :billing_id, :integer, :null => true
  end

  def self.down
  	change_column :subscriptions, :billing_id, :integer, :null => false
  end
end
