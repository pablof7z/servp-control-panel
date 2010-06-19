class CreatePlans < ActiveRecord::Migration
  def self.up
    create_table :plans do |t|
      t.string :name, :null => false
      t.integer :service_id
      t.integer :monthly_fee_cents
      t.string :fees_currency

      t.timestamps
    end
  end

  def self.down
    drop_table :plans
  end
end
