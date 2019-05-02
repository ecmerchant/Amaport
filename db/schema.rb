# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_05_01_074254) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "user_id"
    t.string "seller_id"
    t.string "mws_auth_token"
    t.string "aws_access_key_id"
    t.string "secret_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "keyword_sets", force: :cascade do |t|
    t.string "user_id"
    t.text "keyword"
    t.text "brand_name"
    t.text "manufacturer"
    t.text "recommended_browse_nodes"
    t.text "generic_keywords"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "listing_templates", force: :cascade do |t|
    t.string "user_id"
    t.string "key"
    t.text "caption"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ng_sellers", force: :cascade do |t|
    t.string "user_id"
    t.string "seller_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "price_tables", force: :cascade do |t|
    t.string "user_id"
    t.integer "buy_price"
    t.integer "sell_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "replace_tables", force: :cascade do |t|
    t.string "user_id"
    t.text "from_keyword"
    t.text "to_keyword"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.boolean "admin_flg", default: false, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
