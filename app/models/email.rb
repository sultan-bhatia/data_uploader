class Email < ActiveRecord::Base
  belongs_to :person
  belongs_to :email_type
  
  validates_presence_of :person_id, :email_type_id, :name, :message => "enter all required information"

  validates_uniqueness_of :email_type_id, :scope => :person_id, :message => "Duplicate email type"
  validates_uniqueness_of :name, :message => "Duplicate email address"

end
