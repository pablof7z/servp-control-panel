class CreateBmSubscriptionMetadatas < ActiveRecord::Migration
  def self.up
    create_table :bm_subscription_metadatas do |t|
      t.integer :bm_subscription_id, :null => false
      t.string :keyword, :null => false
      t.string :value

      t.timestamps
    end
  end

  def self.down
    drop_table :bm_subscription_metadatas
  end
end
