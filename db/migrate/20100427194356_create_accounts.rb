class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :name, :null => false
      t.string :mask, :null => false
      t.integer :created_by_id, :null => false
      t.string :url
      t.string :invoice_information

      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
