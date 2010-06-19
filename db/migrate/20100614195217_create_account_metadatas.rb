class CreateAccountMetadatas < ActiveRecord::Migration
  def self.up
    create_table :account_metadatas do |t|
      t.integer :account_id, :null => false
      t.string :keyword, :null => false
      t.string :value

      t.timestamps
    end
  end

  def self.down
    drop_table :account_metadatas
  end
end
