class CreateBillingPaypals < ActiveRecord::Migration
  def self.up
    create_table :billing_paypals do |t|
      t.integer :billing_id, :null => false
      t.string :subscription
      t.integer :amount_cents, :null => false
      t.string :amount_currency, :null => false, :default => DEFAULT_CURRENCY

      t.timestamps
    end
  end

  def self.down
    drop_table :billing_paypals
  end
end
