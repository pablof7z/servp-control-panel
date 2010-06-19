class CreateServerMetadatas < ActiveRecord::Migration
  def self.up
    create_table :server_metadatas do |t|
      t.integer :server_id, :null => false
      t.string :keyword, :null => false
      t.string :value

      t.timestamps
    end
  end

  def self.down
    drop_table :server_metadatas
  end
end
