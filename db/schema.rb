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

ActiveRecord::Schema.define(:version => 20100424063749) do

  create_table "address_types", :force => true do |t|
    t.string   "name",       :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "address_types", ["name"], :name => "index_address_types_on_name", :unique => true

  create_table "addresses", :force => true do |t|
    t.integer  "person_id",                     :null => false
    t.integer  "address_type_id",               :null => false
    t.string   "street_1",        :limit => 60
    t.string   "street_2",        :limit => 60
    t.string   "city",            :limit => 30
    t.string   "state",           :limit => 2
    t.string   "zip_code",        :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "addresses", ["person_id", "address_type_id"], :name => "index_addresses_on_person_id_and_address_type_id", :unique => true

  create_table "data_columns", :force => true do |t|
    t.integer  "upload_template_id",                :null => false
    t.integer  "seq_no",                            :null => false
    t.string   "input_column",       :limit => 100
    t.string   "app_table",          :limit => 100
    t.string   "app_column",         :limit => 100
    t.integer  "data_type_id"
    t.string   "data_type_name",     :limit => 100
    t.integer  "data_year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "data_columns", ["upload_template_id", "seq_no"], :name => "index_data_columns_on_upload_template_id_and_seq_no", :unique => true

  create_table "email_types", :force => true do |t|
    t.string   "name",       :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_types", ["name"], :name => "index_email_types_on_name", :unique => true

  create_table "emails", :force => true do |t|
    t.integer  "person_id",                   :null => false
    t.integer  "email_type_id",               :null => false
    t.string   "name",          :limit => 60, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "emails", ["name"], :name => "index_emails_on_name", :unique => true
  add_index "emails", ["person_id", "email_type_id"], :name => "index_emails_on_person_id_and_email_type_id", :unique => true

  create_table "persons", :force => true do |t|
    t.string   "person_number", :limit => 9
    t.string   "last_name",     :limit => 30
    t.string   "first_name",    :limit => 30
    t.string   "gender",        :limit => 1
    t.date     "birth_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "persons", ["last_name", "first_name"], :name => "index_persons_on_last_name_and_first_name"
  add_index "persons", ["person_number"], :name => "index_persons_on_person_number", :unique => true

  create_table "phone_types", :force => true do |t|
    t.string   "name",       :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "phone_types", ["name"], :name => "index_phone_types_on_name", :unique => true

  create_table "phones", :force => true do |t|
    t.integer  "person_id",                   :null => false
    t.integer  "phone_type_id",               :null => false
    t.string   "name",          :limit => 10, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "phones", ["name"], :name => "index_phones_on_name"
  add_index "phones", ["person_id", "phone_type_id"], :name => "index_phones_on_person_id_and_phone_type_id", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "upload_templates", :force => true do |t|
    t.string   "name",       :limit => 200,                   :null => false
    t.string   "document",   :limit => 1000,                  :null => false
    t.string   "status",     :limit => 1,    :default => "0"
    t.integer  "no_errors"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "upload_templates", ["name"], :name => "index_upload_templates_on_name", :unique => true

end
