class UploadTemplate < ActiveRecord::Base
  has_many :data_columns, :dependent =>:delete_all
  accepts_nested_attributes_for :data_columns
  
  mount_uploader :document, DocumentUploader

  validates_presence_of :name
  validates_presence_of :document

  validates_uniqueness_of :name, :message => "Duplicate template name"

end
