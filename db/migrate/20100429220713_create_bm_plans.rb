class CreateBmPlans < ActiveRecord::Migration
  def self.up
    create_table :bm_plans do |t|
      t.integer :plan_id, :null => false
      t.integer :included_cats, :null => false
      t.integer :additional_cat_price_cents, :null => false
      t.integer :guaranteed_response_time, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :bm_plans
  end
end
