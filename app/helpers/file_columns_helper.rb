module FileColumnsHelper

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
    unless @data_columns.empty?
      @upload_msg = "Problem encountered"
      return
    end

    @column_headers.each_with_index do |h, col_no|
      data_column = DataColumn.new
      data_column.upload_template_id = @upload_template.id
      data_column.seq_no = col_no + 1
      data_column.input_column = h
      data_column.app_table = "none"
      data_column.app_column = "none"
      unless data_column.save
        @upload_msg = "Problem with save"
      end
    end

  end


  def update_columns
    
    @data_columns = @upload_template.data_columns.find(:all, :order => "seq_no")
    if @data_columns.empty?
      @upload_msg = "Problem"
      return
    end

    @data_columns.each_with_index do |h, col_no|
      if col_no < @column_headers.length
        if h.input_column != @column_headers[col_no]
          h.input_column = @column_headers[col_no]
          unless h.save
            @upload_msg = "System problem"
          end
        end
      else
        unless h.destroy
          @upload_msg = "System problem"
        end
      end
    end

    if @data_columns.length < @column_headers.length
      @column_headers.each_with_index do |h, seq_no|
        if seq_no < @data_columns.length
          next
        else
          data_column = DataColumn.new
          data_column.upload_template_id = @upload_template.id
          data_column.seq_no = seq_no+1
          data_column.input_column = h
          data_column.app_table = "none"
          data_column.app_column = "none"
          unless data_column.save
            @upload_msg = "System problem"
          end
        end
      end
    end

  end


end
