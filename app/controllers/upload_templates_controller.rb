require 'csv'

class UploadTemplatesController < ApplicationController

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
    if !@upload_template.save
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
    if !@upload_template.update_attributes(params[:upload_template])
      flash[:notice] = 'There was a problem with updating the template.'
      render :action => "edit" and return
    end

    check_file

    if @upload_msg == nil
      check_columns
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


end
