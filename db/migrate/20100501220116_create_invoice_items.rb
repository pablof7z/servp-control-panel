class CreateInvoiceItems < ActiveRecord::Migration
  def self.up
    create_table :invoice_items do |t|
      t.integer :invoice_id
      t.string :description
      t.integer :quantity
      t.integer :unit_price_cents
      t.currency :unit_price
      t.boolean :is_tax
      t.integer :subscription_period_id
      t.integer :created_by_id

      t.timestamps
    end
  end

  def self.down
    drop_table :invoice_items
  end
end
