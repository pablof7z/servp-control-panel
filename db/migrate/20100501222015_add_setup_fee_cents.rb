class AddSetupFeeCents < ActiveRecord::Migration
  def self.up
  	add_column :plans, :setup_fee_cents, :integer
  	add_column :plans, :setup_fee_currency, :string
  end

  def self.down
  	remove_column :plans, :setup_fee_cents
  	remove_column :plans, :setup_fee_currency
  end
end
