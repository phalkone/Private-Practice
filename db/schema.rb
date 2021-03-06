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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110714002642) do

  create_table "appointments", :force => true do |t|
    t.integer  "doctor_id"
    t.integer  "patient_id"
    t.datetime "begin"
    t.datetime "end"
    t.string   "comment"
    t.integer  "recurrence"
    t.boolean  "completed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "split"
  end

  add_index "appointments", ["doctor_id"], :name => "index_appointments_on_doctor_id"
  add_index "appointments", ["patient_id"], :name => "index_appointments_on_patient_id"

  create_table "images", :force => true do |t|
    t.binary   "picture"
    t.string   "name"
    t.string   "filetype"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["name"], :name => "index_images_on_name", :unique => true

  create_table "messages", :force => true do |t|
    t.integer  "user_id"
    t.string   "email"
    t.string   "name"
    t.string   "subject"
    t.string   "body"
    t.boolean  "read",       :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "page_contents", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.string   "locale"
    t.boolean  "html",       :default => false
    t.integer  "page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.string   "permalink"
    t.boolean  "nested",     :default => false
    t.integer  "sequence"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string "title"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "persistence_token"
    t.string   "perishable_token"
    t.integer  "login_count",        :default => 0,     :null => false
    t.integer  "failed_login_count", :default => 0,     :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.boolean  "confirmed",          :default => false, :null => false
    t.boolean  "active",             :default => true,  :null => false
    t.string   "address"
    t.string   "postcode"
    t.string   "town"
    t.string   "phone"
    t.string   "mobile"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
