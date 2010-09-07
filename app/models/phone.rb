class Phone < ActiveRecord::Base
  belongs_to :person
  belongs_to :phone_type
    
  validates_presence_of :person_id, :phone_type_id, :name, :message => "enter all required information"

  validates_length_of :name, :is => 10, :message => "enter 10 digits for phone number"
  validates_numericality_of :name, :only_integer => true, :message => "enter 10 digits for phone number"

  validates_uniqueness_of :phone_type_id, :scope => "person_id", :message => "Duplicate phone type"
  validates_uniqueness_of :name, :scope => "person_id", :message => "Duplicate phone number"

  def before_validation

    if self.name && self.name != ""
      self.name = self.name.gsub(/\D/, '')
    end

  end







end
