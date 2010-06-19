class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
	  t.string :name
	  t.string :country, :default => 'UNITED STATES'
      t.string :username, :null => false
      t.string :email, :null => false
      t.string :crypted_password, :null => false
	  t.string :password_salt, :null => false
	  t.string :persistence_token
	  t.string :perishable_token
	  t.integer :login_count, :default => 0
	  t.datetime :last_request_at
	  t.datetime :last_login_at
	  t.datetime :current_login_at
	  t.integer :failed_login_count, :default => 0
	  t.string :last_login_ip
	  t.string :current_login_ip
	  t.string :mask

      t.timestamps
    end

	add_index :users, :username
	add_index :users, :persistence_token
	add_index :users, :last_request_at
  end

  def self.down
    drop_table :users
  end
end
