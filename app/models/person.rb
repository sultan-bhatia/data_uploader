class Person < ActiveRecord::Base
  has_many :addresses,  :dependent =>:delete_all
  accepts_nested_attributes_for :addresses
  has_many :address_types, :through => :addresses

  has_many :phones, :dependent =>:delete_all
  accepts_nested_attributes_for :phones
  has_many :phone_types, :through => :phones
  
  has_many :emails, :dependent =>:delete_all
  accepts_nested_attributes_for :emails
  has_many :email_types, :through => :emails
  
  validates_presence_of :last_name, :message => "last name is missing"
  validates_presence_of :first_name, :message => "first name is missing"

end
