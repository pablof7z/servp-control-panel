class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.integer :server_id, :null => false
      t.integer :plan_id, :null => false
      t.boolean :enabled, :default => false
      t.integer :billing_id, :null => false
      t.integer :setup_fee_cents, :null => false
      t.integer :monthly_fee_cents, :null => false
      t.string :setup_fee_currency, :null => false, :default => DEFAULT_CURRENCY
      t.string :monthly_fee_currency, :null => false, :default => DEFAULT_CURRENCY

      t.timestamps
    end
  end

  def self.down
    drop_table :subscriptions
  end
end
