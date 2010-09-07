class Address < ActiveRecord::Base
  belongs_to :person
  belongs_to :address_type

  validates_presence_of :person_id, :address_type_id, :message => "enter all required information"

  validates_uniqueness_of :address_type_id, :scope => "person_id", :message => "Duplicate address type"

end
