class DatabaseTablesController < ApplicationController

  def show

    session[:type_required] = false
    session[:ttype_name] = " "
    session[:data_type_name] = " "
    session[:data_type_id] = " "

    $TABLE_ARR.each {|table| @table = table if (table.name == params[:table_name])}
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


end
