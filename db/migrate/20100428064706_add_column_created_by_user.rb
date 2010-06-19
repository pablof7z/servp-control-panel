class AddColumnCreatedByUser < ActiveRecord::Migration
  def self.up
  	add_column :servers, :created_by_id, :integer, :null => false
  end

  def self.down
  	remove_column :servers, :created_by_id
  end
end
