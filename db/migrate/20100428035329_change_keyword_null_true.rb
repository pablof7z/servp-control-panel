class ChangeKeywordNullTrue < ActiveRecord::Migration
  def self.up
  	change_column :ticket_updates, :keyword, :string, :null => true
  end

  def self.down
  	change_column :ticket_updates, :keyword, :string, :null => false
  end
end
