module FileProcessingHelper


  def read_file_and_update_db
  
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
	  
	  return row_count

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

    @p_data = @p_class.find(:first, :conditions => ["#{@key}"])
    if @p_data
      begin
        @p_data.update_attributes(@datatables[@table_no])
        raise if @p_data.errors.count > 0
      rescue
        @upload_template.no_errors += 1
        @upload_template.notes += "#{@p_class.name} update NOT successful:" + @key
        if @p_data.errors.count > 0
          @p_data.errors.each {|i, msg| @upload_template.notes += ", " + msg}
        end
        @upload_template.notes += "<br>"
        @key = false
      end
    else
      begin
        @p_data = @p_class.new(@datatables[@table_no])
        @p_data.save
        raise if @p_data.errors.count > 0
      rescue
        @upload_template.no_errors += 1
        @upload_template.notes += "#{@p_class.name} save NOT successful:" + @key
        if @p_data.errors.count > 0
          @p_data.errors.each {|i, msg| @upload_template.notes += ", " + msg}
        end
        @upload_template.notes += "<br>"
        @key = false
      end  
    end

  end


  def process_child
    class_name = "none"
    $TABLE_ARR.each {|t| class_name = t.name if (@tname.include? t.name.downcase)}

    c_class = Object.const_get(class_name)
    p_key = @p_class.name.downcase + "_id = #{@p_data.id}"
    if @ikeytables[@table_no][0]
      c_key = p_key + " AND " + class_name.downcase + "_type_id = #{@ikeytables[@table_no][0]}"
    end
    c_data = c_class.find(:first, :conditions => ["#{c_key}"])
    if c_data
      begin
        c_data.update_attributes(@datatables[@table_no])
        raise if c_data.errors.count > 0
      rescue
        @upload_template.no_errors += 1
        @upload_template.notes += "#{c_class.name} update NOT successful:" + c_key
        if c_data.errors.count > 0
          c_data.errors.each {|i, msg| @upload_template.notes += ", " + msg}
        else
          @key = false
        end
        @upload_template.notes += "<br>"
      end
    else
      begin
        item = @p_class.name.downcase + '_id'
        @datatables[@table_no][item] = @p_data.id
        item = class_name.downcase + '_type_id'
        @datatables[@table_no][item] = @ikeytables[@table_no][0]
        c_data = c_class.new(@datatables[@table_no])
        c_data.save
        raise if c_data.errors.count > 0
      rescue
        @upload_template.no_errors += 1
        @upload_template.notes += "#{c_class.name} save NOT successful:" + c_key
        if c_data.errors.count > 0
          c_data.errors.each {|i, msg| @upload_template.notes += ", " + msg}
        else
          @key = false
        end
        @upload_template.notes += "<br>"
      end
    end 

  end


end
