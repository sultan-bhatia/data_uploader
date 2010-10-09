require 'csv'

class DataColumnsController < ApplicationController

  def index

    session[:upload_template] = @upload_template = UploadTemplate.find(params[:id])
    @data_columns = @upload_template.data_columns.find(:all, :order => "seq_no")
	session[:db_table] = nil

    respond_to do |format|
      format.html
      format.xml  {render :xml => @upload_template}
    end

  end


  def edit_data_column

    session[:data_column] = @data_form = DataColumn.find(params[:id])
    @upload_msg = nil

    render :update do |page|
      page.replace_html "map-row-info", :partial=> "data_form", :object => @data_form
    end

  end


  def map_field
  
    @upload_msg = nil
    if session[:data_column] || session[:data_column] != nil
      session[:data_column].app_table = params[:app_table]
      session[:data_column].app_column = params[:app_column]
      if session[:data_type_name] != " "
        session[:data_column].data_type_name = session[:data_type_name]
        session[:data_column].data_type_id = session[:data_type_id]
      else
        @upload_msg = "Please select a type first." if session[:type_required] == true
      end
      @data_form = session[:data_column]
    else
      @upload_msg = "Please select an Input column first."
    end

    render :update do |page|
      if @upload_msg == nil
        page.replace_html "map-row-info", :partial=> "data_form", :object => @data_form
      else
        page.replace_html "map-row-info", :partial=> "layouts/display_msg"
      end
    end

  end


  def map_update
  
    @upload_msg = nil
    @data_form = session[:data_column]
    
    unless @data_form.save
      @upload_msg = "System Problem"
    end

    @data_columns = DataColumn.find(:all, :conditions => ["upload_template_id = ?", @data_form.upload_template_id.to_i], :order => "seq_no")
    session[:data_column] = nil

    render :update do |page|
      if @upload_msg == nil
        page.replace_html "map-row-info", :partial=> "layouts/blank"
        page.replace_html "display-map", :partial => "display_map"
      else
        page.replace_html "map-row-info", :partial=> "layouts/display_msg"
      end
    end


  end


  def map_cancel

    @upload_msg = nil
 
    @data_form = session[:data_column]
    @data_columns = DataColumn.find(:all, :conditions => ["upload_template_id = ?", @data_form.upload_template_id.to_i], :order => "seq_no")
    session[:data_column] = nil

    render :update do |page|
      page.replace_html "map-row-info", :partial=> "layouts/blank"
      page.replace_html "display-map", :partial => "display_map"
    end

  end


  def map_remove

    @upload_msg = nil

    @data_form = session[:data_column]	
    @data_form.app_table = "none"
    @data_form.app_column = "none"
    @data_form.data_type_id = nil
    @data_form.data_type_name = nil
    unless @data_form.save
      @upload_msg = "System problem"
    end

    @data_columns = DataColumn.find(:all, :conditions => ["upload_template_id = ?", @data_form.upload_template_id.to_i], :order => "seq_no")
    session[:data_column] = nil

    render :update do |page|
      if @upload_msg == nil
        page.replace_html "map-row-info", :partial=> "layouts/blank"
        page.replace_html "display-map", :partial => "display_map"
      else
        page.replace_html "map-row-info", :partial=> "layouts/display_msg"
      end
    end


  end


  def map_drop

    @upload_msg = nil
    @data_form = session[:upload_template].data_columns.find_by_seq_no(params[:seq_no])
    @data_form.app_table = session[:db_table].downcase.pluralize
    @data_form.app_column = params[:db_column]
	if session[:data_type_name] != " "
	  @data_form.data_type_name = session[:data_type_name]
	  @data_form.data_type_id = session[:data_type_id]
	else
	  @upload_msg = "Please select a type first." if session[:type_required] == true
	end
    
	if @upload_msg == nil
      unless @data_form.save
        @upload_msg = "System Problem"
      end
	end

    render :update do |page|
      if @upload_msg == nil
		@data_columns = DataColumn.find(:all, :conditions => ["upload_template_id = ?", @data_form.upload_template_id.to_i], :order => "seq_no")
        page.replace_html "map-row-info", :partial=> "layouts/blank"
        page.replace_html "display-map", :partial => "display_map"
      else
        page.replace_html "map-row-info", :partial=> "layouts/display_msg"
		page["map-row-info"].visual_effect :highlight, :endcolor => "#fff85d"
		page["map-row-info"].visual_effect :pulsate
		page["seq-no-#{@data_form.seq_no}"].visual_effect :highlight, :endcolor => "#fff85d"
		page["seq-no-#{@data_form.seq_no}"].visual_effect :pulsate
      end
    end


  end


end
