class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.integer :account_id
      t.integer :subtotal_cents
      t.integer :total_cents
      t.integer :created_by_id
      t.string :recipient
      t.string :from
      t.string :mask
      t.datetime :date
      t.string :currency
      t.float :exchange_rate
      t.boolean :payable
      t.datetime :due_date
      t.datetime :paid

      t.timestamps
    end
  end

  def self.down
    drop_table :invoices
  end
end
