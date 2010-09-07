class DataColumn < ActiveRecord::Base
  belongs_to :upload_template

  validates_presence_of :upload_template_id, :seq_no, :message => "enter all required information"

  validates_uniqueness_of :seq_no, :scope => "upload_template_id"

end
