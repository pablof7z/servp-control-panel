class MoveEnabledToBilling < ActiveRecord::Migration
  def self.up
  	remove_column :subscriptions, :enabled
  	add_column :billings, :enabled, :boolean, :default => false
  end

  def self.down
  	add_column :subscriptions, :enabled, :boolean, :default => false
  	remove_column :billings, :enabled
  end
end
