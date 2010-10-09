class DatabaseTablesController < ApplicationController

  def show

    session[:type_required] = false
	session[:db_table] = nil
    session[:ttype_name] = " "
    session[:data_type_name] = " "
    session[:data_type_id] = " "

    $TABLE_ARR.each {|table| @table = table if (table.name == params[:table_name])}
	session[:db_table] = params[:table_name]
    @ttype == nil
    $TYPE_TABLES.each {|ttype| @ttype = ttype if (ttype.name == params[:table_name] + "Type")}
    if @ttype != nil
      session[:type_required] = true
      session[:ttype_name] = @ttype.name
      @ttype_data = Object.const_get(@ttype.name).find(:all, :order => "name").map {|p| [p.name]}
      @a = []
      @a << ["Select a type"]
      @ttype_data = @a + @ttype_data
    end

    render :update do |page|
      page.replace_html "columns-info", :partial => "show"
    end

  end


  def onchange_data_type_name

    session[:ttype_name] = params[:ttype_name]
    session[:data_type_name] = params[:data_type_name]
    $TYPE_TABLES.each {|ttype| @ttype = ttype if (params[:ttype_name] == ttype.name)}
    session[:data_type_id] = Object.const_get(@ttype.name).find_by_name(params[:data_type_name]).id
    @ttype_data = Object.const_get(@ttype.name).find(:all, :order => "name").map {|p| [p.name]}
    @a = []
    @a << ["#{session[:data_type_name]}"]
    @ttype_data = @ttype_data - @a
    @ttype_data = @a + @ttype_data
    
    $TABLE_ARR.each {|table| @table = table if (params[:table_name] == table.name)}

    render :update do |page|
      page.replace_html "columns-info", :partial => "show"
    end

  end


end
