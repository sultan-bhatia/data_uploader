class AddApplicationTables < ActiveRecord::Migration
  def self.up

    create_table :address_types do |t|
      t.string   :name, :limit => 15
      t.timestamps
    end
    add_index :address_types, [:name], :unique => true  

    create_table :email_types do |t|
      t.string   :name, :limit => 15
      t.timestamps
    end
    add_index :email_types, [:name], :unique => true

    create_table :phone_types do |t|
      t.string   :name, :limit => 15
      t.timestamps
    end
    add_index :phone_types, [:name], :unique => true

    create_table :persons do |t|
      t.string   :person_number,     :limit => 9
      t.string   :last_name,         :limit => 30
      t.string   :first_name,        :limit => 30
      t.string   :gender,            :limit => 1
      t.date     :birth_date
      t.timestamps
    end
    add_index :persons, [:person_number], :unique => true
    add_index :persons, [:last_name, :first_name]


    create_table :addresses do |t|
      t.integer  :person_id,         :null => false
      t.integer  :address_type_id,   :null => false
      t.string   :street_1,          :limit => 60
      t.string   :street_2,          :limit => 60
      t.string   :city,              :limit => 30
      t.string   :state,             :limit => 2
      t.string   :zip_code,          :limit => 10
      t.timestamps
    end
    add_index :addresses, [:person_id, :address_type_id], :unique => true

    create_table :emails do |t|
      t.integer  :person_id,         :null => false
      t.integer  :email_type_id,     :null => false
      t.string   :name,              :limit => 60, :null => false
      t.timestamps
    end
    add_index :emails, [:person_id, :email_type_id], :unique => true
    add_index :emails, [:name], :unique => true   #emails must be unique system wide

    create_table :phones do |t|
      t.integer  :person_id,         :null => false
      t.integer  :phone_type_id,     :null => false
      t.string   :name,              :limit => 10, :null => false
      t.timestamps
    end
    add_index :phones, [:person_id, :phone_type_id], :unique => true
    add_index :phones, [:name]       #non unique index
  
  end

  def self.down
    drop_table :address_types
    drop_table :email_types
    drop_table :phone_types
    drop_table :persons
    drop_table :addresses
    drop_table :emails
    drop_table :phones
  end
end
