# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_01_08_173834) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'orders', force: :cascade do |t|
    t.integer 'user_id'
    t.string 'status'
    t.integer 'telegram_user_id'
    t.bigint 'tariff_id', null: false
    t.integer 'amount'
    t.string 'payment_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['tariff_id'], name: 'index_orders_on_tariff_id'
  end

  create_table 'tariff_files', force: :cascade do |t|
    t.text 'content'
    t.boolean 'sent'
    t.bigint 'tariff_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['tariff_id'], name: 'index_tariff_files_on_tariff_id'
  end

  create_table 'tariffs', force: :cascade do |t|
    t.string 'name'
    t.decimal 'price'
    t.string 'file_path'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'users', force: :cascade do |t|
    t.string 'telegram_chat_id'
    t.string 'username'
    t.string 'first_name'
    t.string 'last_name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_foreign_key 'orders', 'tariffs'
  add_foreign_key 'tariff_files', 'tariffs'
end
