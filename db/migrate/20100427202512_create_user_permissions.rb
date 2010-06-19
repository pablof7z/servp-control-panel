class CreateUserPermissions < ActiveRecord::Migration
  def self.up
    create_table :user_permissions do |t|
      t.integer :user_id, :null => false
      t.integer :account_id, :null => false
      t.integer :set_by_user_id
      t.boolean :tickets, :default => true
      t.boolean :billing, :default => true
      t.boolean :users, :default => true
      t.boolean :reports, :default => true
      t.boolean :servers, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :user_permissions
  end
end
