class AddUploaderTables < ActiveRecord::Migration

  def self.up

    create_table "upload_templates", :force => true do |t|
      t.string   "name", :limit => 200,  :null => false
      t.string   "document",     :limit => 1000, :null => false
      t.string   "status",         :limit => 1,    :default => "0" #0=initial-setup, 1=not-processed, 2=processed
      t.integer  "no_errors"
      t.text     "notes"
      t.timestamps
    end
    add_index "upload_templates", ["name"], :unique => true

    create_table :data_columns, :force => true do |t|
      t.integer  :upload_template_id, :null => false
      t.integer  :seq_no,          :null => false
      t.string   :input_column,    :limit => 100
      t.string   :app_table,       :limit => 100
      t.string   :app_column,      :limit => 100
      t.integer  :data_type_id
      t.string   :data_type_name,  :limit => 100
      t.integer  :data_year
      t.timestamps
    end
    add_index :data_columns, [:upload_template_id, :seq_no], :unique => true

  end

  def self.down
    drop_table :upload_templates
    drop_table :data_columns
  end
end
