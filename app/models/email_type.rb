class EmailType < ActiveRecord::Base
  has_many :emails #no cascade delete
  
  validates_presence_of :name, :message => "enter all required information"

  validates_uniqueness_of :name
end
