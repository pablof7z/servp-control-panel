# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100620005006) do

  create_table "account_metadatas", :force => true do |t|
    t.integer  "account_id", :null => false
    t.string   "keyword",    :null => false
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounts", :force => true do |t|
    t.string   "name",                :null => false
    t.string   "mask",                :null => false
    t.integer  "created_by_id",       :null => false
    t.string   "url"
    t.string   "invoice_information"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "applied_coupon_subscriptions", :force => true do |t|
    t.integer  "applied_coupon_id", :null => false
    t.integer  "subscription_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "applied_coupons", :force => true do |t|
    t.integer  "coupon_code_id", :null => false
    t.integer  "account_id",     :null => false
    t.datetime "start",          :null => false
    t.datetime "finish",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "billing_paypals", :force => true do |t|
    t.integer  "billing_id",                         :null => false
    t.string   "subscription"
    t.integer  "amount_cents",                       :null => false
    t.string   "amount_currency", :default => "USD", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "billings", :force => true do |t|
    t.string   "mask",       :null => false
    t.string   "source",     :null => false
    t.integer  "account_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bm_plans", :force => true do |t|
    t.integer  "plan_id",                    :null => false
    t.integer  "included_cats",              :null => false
    t.integer  "additional_cat_price_cents", :null => false
    t.integer  "guaranteed_response_time",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bm_subscription_metadatas", :force => true do |t|
    t.integer  "bm_subscription_id", :null => false
    t.string   "keyword",            :null => false
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bm_subscription_periods", :force => true do |t|
    t.integer  "subscription_period_id",                    :null => false
    t.integer  "total_cats",                                :null => false
    t.integer  "used_cats",                  :default => 0, :null => false
    t.integer  "additional_cat_price_cents"
    t.integer  "guaranteed_response_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bm_subscriptions", :force => true do |t|
    t.integer  "subscription_id",                         :null => false
    t.string   "service_provider", :default => "unknown", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "country"
    t.string   "mask"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contact_details", :force => true do |t|
    t.integer  "user_id",                        :null => false
    t.string   "mechanism",                      :null => false
    t.string   "information",                    :null => false
    t.boolean  "emergency",   :default => false
    t.boolean  "newsletter",  :default => true
    t.boolean  "enabled",     :default => true
    t.string   "mask",                           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", :force => true do |t|
    t.string  "iso"
    t.string  "name"
    t.string  "printable_name"
    t.string  "iso3"
    t.integer "numcode"
  end

  create_table "coupon_codes", :force => true do |t|
    t.string   "code",                       :null => false
    t.date     "not_before"
    t.date     "not_after"
    t.integer  "max_total",                  :null => false
    t.integer  "max_account", :default => 1, :null => false
    t.integer  "validity",                   :null => false
    t.string   "affects",                    :null => false
    t.integer  "amount",                     :null => false
    t.string   "amount_unit",                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description",                :null => false
  end

  create_table "invoice_items", :force => true do |t|
    t.integer  "invoice_id"
    t.string   "description"
    t.integer  "quantity"
    t.integer  "unit_price_cents"
    t.boolean  "is_tax"
    t.integer  "subscription_period_id"
    t.integer  "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoices", :force => true do |t|
    t.integer  "account_id"
    t.integer  "subtotal_cents"
    t.integer  "total_cents"
    t.integer  "created_by_id"
    t.string   "recipient"
    t.string   "from"
    t.string   "mask"
    t.datetime "date"
    t.string   "currency"
    t.float    "exchange_rate"
    t.boolean  "payable"
    t.datetime "due_date"
    t.datetime "paid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "newsfeed_items", :force => true do |t|
    t.integer  "user_id"
    t.string   "text"
    t.integer  "account_id"
    t.integer  "server_id"
    t.integer  "ticket_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plans", :force => true do |t|
    t.string   "name",               :null => false
    t.integer  "service_id"
    t.integer  "monthly_fee_cents"
    t.string   "fees_currency"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "setup_fee_cents"
    t.string   "setup_fee_currency"
  end

  create_table "server_informations", :force => true do |t|
    t.integer  "server_id",  :null => false
    t.string   "keyword",    :null => false
    t.string   "value"
    t.boolean  "verified"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "server_metadatas", :force => true do |t|
    t.integer  "server_id",  :null => false
    t.string   "keyword",    :null => false
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "servers", :force => true do |t|
    t.integer  "account_id"
    t.string   "name"
    t.string   "private_notes"
    t.string   "public_notes"
    t.boolean  "enabled"
    t.string   "description"
    t.string   "hostname"
    t.string   "mask"
    t.string   "server_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id", :null => false
  end

  create_table "services", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_periods", :force => true do |t|
    t.datetime "start",           :null => false
    t.datetime "end",             :null => false
    t.integer  "subscription_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "server_id",                               :null => false
    t.integer  "plan_id",                                 :null => false
    t.boolean  "enabled",              :default => false
    t.integer  "billing_id"
    t.integer  "setup_fee_cents",                         :null => false
    t.integer  "monthly_fee_cents",                       :null => false
    t.string   "setup_fee_currency",   :default => "USD", :null => false
    t.string   "monthly_fee_currency", :default => "USD", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ticket_updates", :force => true do |t|
    t.integer  "ticket_id",  :null => false
    t.integer  "user_id",    :null => false
    t.string   "keyword"
    t.string   "value"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tickets", :force => true do |t|
    t.string   "ticket_type",                          :null => false
    t.string   "mask",                                 :null => false
    t.string   "subject"
    t.string   "from"
    t.string   "reply_to"
    t.string   "cc"
    t.string   "text"
    t.integer  "created_by_id",                        :null => false
    t.string   "status",         :default => "New",    :null => false
    t.string   "assigned_to_id"
    t.integer  "account_id"
    t.integer  "server_id"
    t.string   "priority",       :default => "Normal"
    t.datetime "grabbed_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_permissions", :force => true do |t|
    t.integer  "user_id",                          :null => false
    t.integer  "account_id",                       :null => false
    t.integer  "set_by_user_id"
    t.boolean  "tickets",        :default => true
    t.boolean  "billing",        :default => true
    t.boolean  "users",          :default => true
    t.boolean  "reports",        :default => true
    t.boolean  "servers",        :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "country",            :default => "UNITED STATES"
    t.string   "username",                                        :null => false
    t.string   "email",                                           :null => false
    t.string   "crypted_password",                                :null => false
    t.string   "password_salt",                                   :null => false
    t.string   "persistence_token"
    t.string   "perishable_token"
    t.integer  "login_count",        :default => 0
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.integer  "failed_login_count", :default => 0
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.string   "mask"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",               :default => "user",          :null => false
  end

  add_index "users", ["last_request_at"], :name => "index_users_on_last_request_at"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"
  add_index "users", ["username"], :name => "index_users_on_username"

end
