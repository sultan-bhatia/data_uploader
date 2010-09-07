require 'csv'

class ExcelUploadsController < ApplicationController

  def index

    @excel_uploads = ExcelUpload.find(:all, :order => "created_at")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @excel_uploads }
    end

  end


  def map_data

    @excel_upload = ExcelUpload.find(params[:id])
    @excel_columns = @excel_upload.excel_columns.find(:all, :order => "seq_no")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @excel_uploads }
    end
  end


  def show
    @excel_upload = ExcelUpload.find(params[:id])
    @excel_columns = @excel_upload.excel_columns.find(:all, :order => "seq_no")

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @excel_upload }
    end
  end


  def new
    @excel_upload = ExcelUpload.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @excel_upload }
    end
  end


  def edit
    @excel_upload = ExcelUpload.find(params[:id])
  end


  def create

    @excel_upload = ExcelUpload.new(params[:excel_upload])
    if !@excel_upload.save
      flash[:notice] = 'There was a problem with creating the template.'
      render :action => "new" and return
    end

    check_file

    if @upload_msg == nil
      create_columns
    end

    respond_to do |format|
      if @upload_msg == nil
        flash[:notice] = 'ExcelUpload Template was successfully created.'
        format.html { redirect_to(@excel_upload) }
        format.xml  { render :xml => @excel_upload, :status => :created, :location => @excel_upload }
      else
        @excel_upload.destroy
        @excel_upload.excel_template = @upload_msg
        flash[:notice] = 'There was a problem with creating the template.'
        format.html { render :action => "new" }
        format.xml  { render :xml => @excel_upload.errors, :status => :unprocessable_entity }
      end
    end

  end


  def update

    @excel_upload = ExcelUpload.find(params[:id])
    params[:excel_upload][:status] = "N"
    params[:excel_upload][:no_errors] = 0
    params[:excel_upload][:notes] = " "
    if !@excel_upload.update_attributes(params[:excel_upload])
      flash[:notice] = 'There was a problem with updating the template.'
      render :action => "edit" and return
    end

    check_file

    if @upload_msg == nil
      check_columns
    end

    respond_to do |format|
      if @upload_msg == nil
        flash[:notice] = 'ExcelUpload Template was successfully updated.'
        format.html { redirect_to(@excel_upload) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @excel_upload.errors, :status => :unprocessable_entity }
      end
    end
  end


  def destroy
    @excel_upload = ExcelUpload.find(params[:id])
    @excel_upload.destroy

    respond_to do |format|
      format.html { redirect_to(excel_uploads_url) }
      format.xml  { head :ok }
    end
  end


  def check_file

    @upload_msg = nil

    @parsed_file=CSV.parse(@excel_upload.document.to_s)
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
    
    @excel_columns = @excel_upload.excel_columns.find(:all, :order => "seq_no")
    if !@excel_columns.empty?
      @upload_msg = "Problem encountered"
      return
    end

    seq_no = 0
    @column_headers.each do |h|
      seq_no += 1
      excel_column = ExcelColumn.new
      excel_column.excel_upload_id = @excel_upload.id
      excel_column.seq_no = seq_no
      excel_column.excel_column = h
      excel_column.app_table = "none"
      excel_column.app_column = "none"
      if !excel_column.save
        @upload_msg = "Problem with save"
      end
    end

  end


  def check_columns
    
    @excel_columns = @excel_upload.excel_columns.find(:all, :order => "seq_no")
    if @excel_columns.empty?
      @upload_msg = "Problem"
      return
    end

    col_no = 0
    @excel_columns.each do |h|
      col_no += 1
      if col_no <= @column_headers.length
        if h.excel_column != @column_headers[col_no-1]
          h.excel_column = @column_headers[col_no-1]
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
          excel_column = ExcelColumn.new
          excel_column.excel_upload_id = @excel_upload.id
          excel_column.seq_no = seq_no
          excel_column.excel_column = h
          excel_column.app_table = "none"
          excel_column.app_column = "none"
          if !excel_column.save
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
    session[:data_type_id] = @ttype.find_by_name(params[:data_type_name]).id
    @ttype_data = @ttype.find(:all, :order => "name").map {|p| [p.name]}
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

    session[:excel_column] = @column_form = ExcelColumn.find(params[:id])
    @upload_msg = nil

    render :update do |page|
      page.replace_html "map-row-info", :partial=>'column_form', :object => @column_form
    end

  end


  def map_field

    @upload_msg = nil
    if session[:excel_column] || session[:excel_column] != nil
      session[:excel_column].app_table = params[:app_table]
      session[:excel_column].app_column = params[:app_column]
      if session[:data_type_name] != " "
        session[:excel_column].data_type_name = session[:data_type_name]
        session[:excel_column].data_type_id = session[:data_type_id]
      else
        @upload_msg = "Please select a type first." if session[:type_required] == true
      end
      @column_form = session[:excel_column]
    else
      @upload_msg = "Please select an Excel column first."
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
    @column_form = ExcelColumn.find(session[:excel_column].id)
    @column_form.app_table = session[:excel_column].app_table
    @column_form.app_column = session[:excel_column].app_column
    @column_form.data_type_name = session[:data_type_name]
    @column_form.data_type_id = session[:data_type_id]
    
    if !@column_form.save
      @upload_msg = "System Problem"
    end

    @excel_columns = ExcelColumn.find(:all, :conditions => ["excel_upload_id = ?", @column_form.excel_upload_id.to_i], :order => "seq_no")
    session[:excel_column] = nil

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
    @column_form = ExcelColumn.find(session[:excel_column].id)
    @excel_columns = ExcelColumn.find(:all, :conditions => ["excel_upload_id = ?", @column_form.excel_upload_id.to_i], :order => "seq_no")
    session[:excel_column] = nil

    render :update do |page|
      page.replace_html "map-row-info", :partial=>'blank'
      page.replace_html "display-map", :partial => "display_map"
    end

  end


  def map_remove

    @upload_msg = nil
    @column_form = ExcelColumn.find(session[:excel_column].id)
    @column_form.app_table = "none"
    @column_form.app_column = "none"
    @column_form.data_type_id = nil
    @column_form.data_type_name = nil
    if !@column_form.save
      @upload_msg = "System problem"
    end

    @excel_columns = ExcelColumn.find(:all, :conditions => ["excel_upload_id = ?", @column_form.excel_upload_id.to_i], :order => "seq_no")
    session[:excel_column] = nil

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

    doc = ExcelUpload.find(params[:id]).document.to_s
    send_file(doc, :type => :text, :disposition => 'inline') and return

  end


  def process_file

    @excel_upload = ExcelUpload.find(params[:id])
    @excel_upload.no_errors = 0
    @excel_upload.notes = " "
    @excel_columns = @excel_upload.excel_columns.find(:all, :order => "seq_no")
  
    @tablenames = []
    @attrtables = []
    table_no = -1
    @excel_columns.each do |h|
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
      @parsed_file=CSV.parse(@excel_upload.document.to_s)
      @parsed_file.each  do |row|
        row_count += 1
        if row_count == 1
          @column_headers = row
        else
          @column_data = row
          process_data
        end
      end

    @excel_upload.status = "P"
    if !@excel_upload.save
      logger.info "Upload status could not be set to 'P'"
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
    @excel_columns.each do |excel_column|
      item = @column_data[excel_column.seq_no - 1]
      item = item.strip if item.nil?
      t = excel_column.app_table
      t += excel_column.data_type_name if excel_column.data_type_name?
      @tablenames.each_with_index do |tname, i|
        if tname == t
          @itemtables[i] << item
          @ikeytables[i][0] = excel_column.data_type_id
          @ikeytables[i][1] = excel_column.data_type_name
          break
        end
      end
    end  #@excel_columns.each do |excel_column|
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

    class_name = @excel_columns[0].app_table.split('_').collect { |word| word.capitalize }.join.singularize
    @p_class = Object.const_get(class_name)
    @key = @excel_columns[0].app_column + " = '#{@column_data[0]}'"

    @p_table = @p_class.find(:first, :conditions => ["#{@key}"])
    if @p_table
      begin
        @p_table.update_attributes(@datatables[@table_no])
      rescue
        logger.info "#{@p_class.name} update NOT successful:" + @key
        @excel_upload.no_errors += 1
        @excel_upload.notes += "#{@p_class.name} update NOT successful:" + @key + "<br>"
        @key = false
      end
    else
      begin
        @p_class.create(@datatables[@table_no])
        @p_table = @p_class.find(:first, :conditions => ["#{@key}"])
      rescue
        logger.info "#{@p_class.name} save NOT successful:" + @key
        @excel_upload.no_errors += 1
        @excel_upload.notes += "#{@p_class.name} save NOT successful:" + @key + "<br>"
        @key = false
      end  
    end

  end


  def process_child

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
      rescue
        logger.info "#{c_class.name} update NOT successful:" + c_key
        @excel_upload.no_errors += 1
        @excel_upload.notes += "#{c_class.name} update NOT successful:" + c_key + "<br>"
        @key = false
      end
    else
      begin
        item = @p_class.name.downcase + '_id'
        @datatables[@table_no][item] = @p_table.id
        item = class_name.downcase + '_type_id'
        @datatables[@table_no][item] = @ikeytables[@table_no][0]
        c_class.create(@datatables[@table_no])
        c_table = c_class.find(:first, :conditions => ["#{c_key}"])
      rescue
        logger.info "#{c_class.name} save NOT successful:" + c_key
        @excel_upload.no_errors += 1
        @excel_upload.notes += "#{c_class.name} save NOT successful:" + c_key + "<br>"
        @key = false
      end
    end 

  end


end
