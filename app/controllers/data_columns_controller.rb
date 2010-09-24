require 'csv'

class DataColumnsController < ApplicationController

  def index

    @upload_template = UploadTemplate.find(params[:id])
    @data_columns = @upload_template.data_columns.find(:all, :order => "seq_no")

    respond_to do |format|
      format.html
      format.xml  { render :xml => @upload_template }
    end

  end


end
