class AddressType < ActiveRecord::Base
  unloadable
  has_many :addresses #no cascade delete
  
  validates_presence_of :name, :message => "enter all required information"

  validates_uniqueness_of :name

end
