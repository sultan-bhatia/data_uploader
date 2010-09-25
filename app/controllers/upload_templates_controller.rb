require 'csv'

class UploadTemplatesController < ApplicationController

  include FileColumnsHelper
  include FileProcessingHelper

  def index

    @upload_templates = UploadTemplate.find(:all, :order => "created_at")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @upload_templates }
    end

  end


  def show

    @upload_template = UploadTemplate.find(params[:id])
    @data_columns = @upload_template.data_columns.find(:all, :order => "seq_no")

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @upload_template }
    end
  end


  def new

    @upload_template = UploadTemplate.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @upload_template }
    end
  end


  def edit

    @upload_template = UploadTemplate.find(params[:id])

  end


  def create

    @upload_template = UploadTemplate.new(params[:upload_template])
    unless @upload_template.save
      flash[:notice] = 'There was a problem with creating the template.'
      render :action => "new" and return
    end

    check_file

    if @upload_msg == nil
      create_columns
    end

    respond_to do |format|
      if @upload_msg == nil
        flash[:notice] = 'Template was successfully created.'
        format.html { redirect_to(@upload_template) }
        format.xml  { render :xml => @upload_template, :status => :created, :location => @upload_template }
      else
        @upload_template.destroy
        @upload_template.name = @upload_msg
        flash[:notice] = 'There was a problem with creating the template.'
        format.html { render :action => "new" }
        format.xml  { render :xml => @upload_template.errors, :status => :unprocessable_entity }
      end
    end

  end


  def update

    @upload_template = UploadTemplate.find(params[:id])
    params[:upload_template][:status] = "0"
    params[:upload_template][:no_errors] = 0
    params[:upload_template][:notes] = " "
    unless @upload_template.update_attributes(params[:upload_template])
      flash[:notice] = 'There was a problem with updating the template.'
      render :action => "edit" and return
    end

    check_file

    if @upload_msg == nil
      update_columns
    end

    respond_to do |format|
      if @upload_msg == nil
        flash[:notice] = 'Template was successfully updated.'
        format.html { redirect_to(@upload_template) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @upload_template.errors, :status => :unprocessable_entity }
      end
    end

  end


  def destroy

    @upload_template = UploadTemplate.find(params[:id])
    @upload_template.destroy

    respond_to do |format|
      format.html { redirect_to(upload_templates_url) }
      format.xml  { head :ok }
    end

  end


  def view_file

    doc = UploadTemplate.find(params[:id]).document.to_s
    send_file(doc, :type => :text, :disposition => 'inline') and return

  end


  def process_file

    @upload_template = UploadTemplate.find(params[:id])
    @upload_template.status = "1"
    @upload_template.no_errors = 0
    @upload_template.notes = " "
    @data_columns = @upload_template.data_columns.find(:all, :order => "seq_no")
	
	row_count = read_file_and_update_db
		
    @upload_template.status = "2"
    if !@upload_template.save
      logger.info "Upload status could not be set to '2'"
    end

    render :update do |page|
        @upload_msg = "File uploaded succesfully. Total #{row_count} rows. "
        (@upload_msg += "Total #{@upload_template.no_errors} errors.") if @upload_template.no_errors > 0
        page.replace_html "map-template-info", :partial => "template_info" 
        page.replace_html "map-row-info", :partial => "layouts/display_msg"
    end

  end  


end
