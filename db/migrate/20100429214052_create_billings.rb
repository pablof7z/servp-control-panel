class CreateBillings < ActiveRecord::Migration
  def self.up
    create_table :billings do |t|
      t.string :mask, :null => false
      t.string :source, :null => false
      t.integer :account_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :billings
  end
end
