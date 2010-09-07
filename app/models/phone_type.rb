class PhoneType < ActiveRecord::Base
  has_many :phones #no cascade delete
  
  validates_presence_of :name, :message => "enter all required information"

  validates_uniqueness_of :name

end
