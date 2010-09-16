require 'csv'

class UploadTemplatesController < ApplicationController

  def index

    @upload_templates = UploadTemplate.find(:all, :order => "created_at")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @upload_templates }
    end

  end


  def map_data

    @upload_template = UploadTemplate.find(params[:id])
    @data_columns = @upload_template.data_columns.find(:all, :order => "seq_no")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @upload_template }
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


  def check_file

    @upload_msg = nil

    @parsed_file=CSV.parse(@upload_template.document.to_s)
    @parsed_file.each  do |row|
      @column_headers = row
      if @column_headers.length <= 1 || @column_headers[0].length >= 100
        @upload_msg = "upload file is wrong format"
        flash[:notice] = "upload file is wrong format"
      end
      break
    end

  end


  def create_columns
    
    @data_columns = @upload_template.data_columns.find(:all, :order => "seq_no")
    if !@data_columns.empty?
      @upload_msg = "Problem encountered"
      return
    end

    seq_no = 0
    @column_headers.each do |h|
      seq_no += 1
      data_column = DataColumn.new
      data_column.upload_template_id = @upload_template.id
      data_column.seq_no = seq_no
      data_column.input_column = h
      data_column.app_table = "none"
      data_column.app_column = "none"
      if !data_column.save
        @upload_msg = "Problem with save"
      end
    end

  end


  def check_columns
    
    @data_columns = @upload_template.data_columns.find(:all, :order => "seq_no")
    if @data_columns.empty?
      @upload_msg = "Problem"
      return
    end

    col_no = 0
    @data_columns.each do |h|
      col_no += 1
      if col_no <= @column_headers.length
        if h.input_column != @column_headers[col_no-1]
          h.input_column = @column_headers[col_no-1]
          if !h.save
            @upload_msg = "System problem"
          end
        end
      else
        if !h.destroy
          @upload_msg = "System problem"
        end
      end
    end

    if col_no < @column_headers.length
      seq_no = 0
      @column_headers.each do |h|
        seq_no += 1
        if seq_no <= col_no
          next
        else
          data_column = DataColumn.new
          data_column.upload_template_id = @upload_template.id
          data_column.seq_no = seq_no
          data_column.input_column = h
          data_column.app_table = "none"
          data_column.app_column = "none"
          if !data_column.save
            @upload_msg = "System problem"
          end
        end
      end
    end

  end


  def table_columns

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
      page.replace_html "columns-info", :partial => "table_columns"
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
      page.replace_html "columns-info", :partial => "table_columns"
    end

  end

  def map_input

    session[:data_column] = @column_form = DataColumn.find(params[:id])
    @upload_msg = nil

    render :update do |page|
      page.replace_html "map-row-info", :partial=>'column_form', :object => @column_form
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
      @column_form = session[:data_column]
    else
      @upload_msg = "Please select an Input column first."
    end

    render :update do |page|
      if @upload_msg == nil
        page.replace_html "map-row-info", :partial=>'column_form', :object => @column_form
      else
        page.replace_html "map-row-info", :partial=>'display_msg'
      end
    end

  end


  def map_update

    @upload_msg = nil
    @column_form = DataColumn.find(session[:data_column].id)
    @column_form.app_table = session[:data_column].app_table
    @column_form.app_column = session[:data_column].app_column
    @column_form.data_type_name = session[:data_type_name]
    @column_form.data_type_id = session[:data_type_id]
    
    if !@column_form.save
      @upload_msg = "System Problem"
    end

    @data_columns = DataColumn.find(:all, :conditions => ["upload_template_id = ?", @column_form.upload_template_id.to_i], :order => "seq_no")
    session[:data_column] = nil

    render :update do |page|
      if @upload_msg == nil
        page.replace_html "map-row-info", :partial=>'blank'
        page.replace_html "display-map", :partial => "display_map"
      else
        page.replace_html "map-row-info", :partial=>'display_msg'
      end
    end


  end


  def map_cancel

    @upload_msg = nil
    @column_form = DataColumn.find(session[:data_column].id)
    @data_columns = DataColumn.find(:all, :conditions => ["upload_template_id = ?", @column_form.upload_template_id.to_i], :order => "seq_no")
    session[:data_column] = nil

    render :update do |page|
      page.replace_html "map-row-info", :partial=>'blank'
      page.replace_html "display-map", :partial => "display_map"
    end

  end


  def map_remove

    @upload_msg = nil
    @column_form = DataColumn.find(session[:data_column].id)
    @column_form.app_table = "none"
    @column_form.app_column = "none"
    @column_form.data_type_id = nil
    @column_form.data_type_name = nil
    if !@column_form.save
      @upload_msg = "System problem"
    end

    @data_columns = DataColumn.find(:all, :conditions => ["upload_template_id = ?", @column_form.upload_template_id.to_i], :order => "seq_no")
    session[:data_column] = nil

    render :update do |page|
      if @upload_msg == nil
        page.replace_html "map-row-info", :partial=>'blank'
        page.replace_html "display-map", :partial => "display_map"
      else
        page.replace_html "map-row-info", :partial=>'display_msg'
      end
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
  
    @tablenames = []
    @attrtables = []
    table_no = -1
    @data_columns.each do |h|
      t = h.app_table
      t += h.data_type_name if h.data_type_name != " "
      if !@tablenames.include? t
        @tablenames << t
        table_no += 1
        @attrtables[table_no] = []
      end
      @attrtables[table_no] << h.app_column
    end

      row_count = 0
      @parsed_file=CSV.parse(@upload_template.document.to_s)
      @parsed_file.each  do |row|
        row_count += 1
        if row_count == 1
          @column_headers = row
        else
          @column_data = row
          process_data
        end
      end

    @upload_template.status = "2"
    if !@upload_template.save
      logger.info "Upload status could not be set to '2'"
    end

    render :update do |page|
        @upload_msg = "File uploaded succesfully. Total #{row_count} rows"
        page.replace_html "map-row-info", :partial => "display_msg"       
    end 

  end


  def process_data

    @itemtables = []
    @ikeytables = []
    @tablenames.each_with_index do |t, i|
      @itemtables[i] = []
      @ikeytables[i] = []
    end
    @data_columns.each do |data_column|
      item = @column_data[data_column.seq_no - 1]
      item = item.strip if item.nil?
      t = data_column.app_table
      t += data_column.data_type_name if data_column.data_type_name?
      @tablenames.each_with_index do |tname, i|
        if tname == t
          @itemtables[i] << item
          @ikeytables[i][0] = data_column.data_type_id
          @ikeytables[i][1] = data_column.data_type_name
          break
        end
      end
    end  #@data_columns.each do |data_column|
    @datatables = []
    @tablenames.each_with_index do |tname, i|
      @datatables[i] = {}
      @datatables[i] = @attrtables[i].inject({}) do |hash,attribute|
        hash[attribute] = @itemtables[i].shift
        hash
      end
    end # tname

    @tablenames.each_with_index do |@tname, @table_no|
      (@table_no == 0) ? process_parent : process_child
      break unless @key
    end

  end


  def process_parent

    class_name = @data_columns[0].app_table.split('_').collect { |word| word.capitalize }.join.singularize
    @p_class = Object.const_get(class_name)
    @key = @data_columns[0].app_column + " = '#{@column_data[0]}'"

    @p_table = @p_class.find(:first, :conditions => ["#{@key}"])
    if @p_table
      begin
        @p_table.update_attributes(@datatables[@table_no])
      rescue
        logger.info "#{@p_class.name} update NOT successful:" + @key
        @upload_template.no_errors += 1
        @upload_template.notes += "#{@p_class.name} update NOT successful:" + @key + "<br>"
        @key = false
      end
    else
      begin
        @p_class.create(@datatables[@table_no])
        @p_table = @p_class.find(:first, :conditions => ["#{@key}"])
      rescue
        logger.info "#{@p_class.name} save NOT successful:" + @key
        @upload_template.no_errors += 1
        @upload_template.notes += "#{@p_class.name} save NOT successful:" + @key + "<br>"
        @key = false
      end  
    end

  end


  def process_child
    logger.info "PROCESS_CHILD"
    class_name = "none"
    $TABLE_ARR.each {|t| class_name = t.name if (@tname.include? t.name.downcase)}

    c_class = Object.const_get(class_name)
    c_key = @p_class.name.downcase + "_id = #{@p_table.id}"
    if @ikeytables[@table_no][0]
      c_key = c_key + " AND " + class_name.downcase + "_type_id = #{@ikeytables[@table_no][0]}"
    end
    c_table = c_class.find(:first, :conditions => ["#{c_key}"])
    if c_table
      begin
        c_table.update_attributes(@datatables[@table_no])
        logger_info "c_table exists"
      rescue
        logger.info "#{c_class.name} update NOT successful:" + c_key
        @upload_template.no_errors += 1
        @upload_template.notes += "#{c_class.name} update NOT successful:" + c_key + "<br>"
        @key = false
      end
    else
      begin
        item = @p_class.name.downcase + '_id'
        @datatables[@table_no][item] = @p_table.id
        item = class_name.downcase + '_type_id'
        @datatables[@table_no][item] = @ikeytables[@table_no][0]
        c_class.create(@datatables[@table_no])
        logger_info "c_table does not exists"
        c_table = c_class.find(:first, :conditions => ["#{c_key}"])
      rescue
        logger.info "#{c_class.name} save NOT successful:" + c_key
        @upload_template.no_errors += 1
        @upload_template.notes += "#{c_class.name} save NOT successful:" + c_key + "<br>"
        @key = false
      end
    end 

  end


end
