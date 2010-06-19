class CreateContactDetails < ActiveRecord::Migration
  def self.up
    create_table :contact_details do |t|
      t.integer :user_id, :null => false
      t.string :mechanism, :null => false
      t.string :information, :null => false
      t.boolean :emergency, :default => false
      t.boolean :newsletter, :default => true
	  t.boolean :enabled, :default => true
	  t.string :mask, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :contact_details
  end
end
