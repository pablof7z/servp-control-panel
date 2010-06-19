class CreateServers < ActiveRecord::Migration
  def self.up
    create_table :servers do |t|
      t.integer :account_id
      t.string :name
      t.string :private_notes
      t.string :public_notes
      t.boolean :enabled
      t.string :description
      t.string :hostname
      t.string :mask
      t.string :server_type

      t.timestamps
    end
  end

  def self.down
    drop_table :servers
  end
end
