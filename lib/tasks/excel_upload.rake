task :excel_upload => [:environment] do |t|

  require 'fastercsv'

  logger.info "START excel_upload:" + Time.now.to_s(:db)

  File.open("public/excel_upload/excel_upload-log.txt", "a") do |logfile|
    logfile.puts Time.now.to_s(:db)
    logfile.puts "start excel_upload====================================="
    
    @excel_upload = ExcelUpload.find(:first, :conditions => ["status = 'U'"], :order => "created_at")
    if !@excel_upload
      logfile.puts "No excel_upload to upload"
      break
    end
    @excel_upload.no_errors = 0
    @excel_upload.notes = " "
    @excel_columns = @excel_upload.excel_columns.find(:all, :order => "seq_no")
    if @excel_columns.empty?
      logfile.puts "No excel_columns to upload"
      @excel_upload.no_errors += 1
      @excel_upload.notes += "No excel_columns to upload<br>"
      break
    end

    logfile.puts @excel_upload.excel_file

    @tablenames = []
    @tablenames[0] = "profiles"
    @excel_columns.each do |h|
      t = h.app_table
      t += h.data_type_name if h.data_type_name
      t += h.data_year.to_s if h.data_year
      if @tablenames.include? t
      else
        @tablenames << t
      end
    end
    logfile.puts "11111111111111111111111111"
    logfile.puts @tablenames
    logfile.puts "11111111111111111111111111"

    @attrtables = []
    table_no = 0
    @tablenames.each do |tname|
      @attrtables[table_no] = []
      table_no += 1
    end

    @excel_columns.each do |h|
      t = h.app_table
      t += h.data_type_name if h.data_type_name
      t += h.data_year.to_s if h.data_year
      table_no = 0
      @tablenames.each do |tname|
        if tname == t
          @attrtables[table_no] << h.app_column
          break
        end
        table_no += 1
      end
    end
    logfile.puts "222222222222222222222222"
    logfile.puts @attrtables
    logfile.puts "222222222222222222222222"

    count = 0
    invalidcount = 0

    logfile.puts "*********sultan-excel_upload-test********" 
    link_file = @excel_upload.excel_file
    logfile.puts link_file

    if !link_file || link_file == nil || link_file == "" || link_file == " "
      logfile.puts "NO csv upload_file"
      link_file = nil
      @excel_upload.no_errors += 1
      @excel_upload.notes += "NO csv upload_file<br>"
    else
      alt_link_file = link_file.gsub(/\\/, '/')
      Rails.logger.debug alt_link_file
      @excel_upload.excel_file = link_file
      Rails.logger.debug "sultan csv:" + link_file
      link_file = alt_link_file
      l = link_file.length
      if link_file[0..1] == "T:"
        link_file = link_file[2..l-1]
      end
      Rails.logger.debug link_file
      alt_link_file = File.join("/mnt/ms-common", link_file)
      Rails.logger.debug "alt_link_file:" + alt_link_file
      row_count = 0
      FasterCSV.foreach(alt_link_file, {:headers => false}) do |row|
        row_count += 1
        if row_count == 1
          @column_headers = row
        else
          @itemtables = []
          @ikeytables = []
          table_no = 0
          @tablenames.each do |t|
            @itemtables[table_no] = []
            @ikeytables[table_no] = []
            table_no += 1
          end

          @column_data = row
          uin = "0"
          college_id = 0
          @excel_columns.each do |excel_column|
            item = @column_data[excel_column.seq_no - 1]
            if item == nil
            else
              item = item.strip
            end

           case  excel_column.app_column

            when "college_id"
             item =  @college_list[item]
             college_id = item
   
            when "uin"
             uin = item

            when "name_last"
             name_last = item

            when "name_first"
             name_first = item

           end # case  excel_column.app_column

           t = excel_column.app_table
           t += excel_column.data_type_name if excel_column.data_type_name
           t += excel_column.data_year.to_s if excel_column.data_year
           table_no = 0
           @tablenames.each do |tname|
             if tname == t
               @itemtables[table_no] << item
               @ikeytables[table_no][0] = excel_column.data_type_id
               @ikeytables[table_no][1] = excel_column.data_type_name
               @ikeytables[table_no][2] = excel_column.data_year
               break
             end
             table_no += 1
           end
  
          end # @excel_columns.each do |excel_column|

          if !uin || uin == nil || uin == "" || uin == " " || uin == "0"
            logfile.puts "problem!!!!!!!!!!!!!!!!!!!!!!"
            logfile.puts row_count.to_s
            logfile.puts uin
            @excel_upload.no_errors += 1
            @excel_upload.notes += "No uin in row number:" + row_count.to_s + "<br>"
            next
          end

          datatables = []
          table_no = 0
          @tablenames.each do |tname|
            datatables[table_no] = {}
            datatables[table_no] = @attrtables[table_no].inject({}) do |hash,attribute|
              hash[attribute] = @itemtables[table_no].shift
              hash
            end
            table_no += 1
          end # tname

          @profile = Profile.find_by_uin(uin)

          if @profile
            begin
              @profile.update_attributes(datatables[0])
            rescue
              logfile.puts "Profile update NOT successful:" + uin
              @excel_upload.no_errors += 1
              @excel_upload.notes += "Profile update NOT successful:" + uin + "<br>"
              next
            end
          else #if @profile
           datatables[0]['created_by'] = @excel_upload.updated_by
              begin
                Profile.create(datatables[0])
                @profile = Profile.find_by_uin(uin)
              rescue
                logfile.puts "Profile save NOT successful:" + uin
                @excel_upload.no_errors += 1
                @excel_upload.notes += "Profile save NOT successful:" + uin + "<br>"
                next
              end  
          end #if @profile
          
          table_no = 0
          @tablenames.each do |tname|
            if tname.include? "profiles"
              t = uin + ","
              t += @profile.name_last if @profile.name_last
              t += ","
              t += @profile.name_first if @profile.name_first
              t += ","
              t += @profile.name_middle if @profile.name_middle
              logfile.puts t

            elsif tname.include? "email"
              item = @ikeytables[table_no][0]
              @email = EmailAddress.find(:first, :conditions => ["profile_id = ? AND email_type_id = ?", @profile.id, item])
              if @email
                begin
                  @email.update_attributes(datatables[table_no])
                rescue
                  logfile.puts "Email update NOT successful" + uin
                  @excel_upload.no_errors += 1
                  @excel_upload.notes += "Email update NOT successful:" + uin + "<br>"
                end
              else
                datatables[table_no]['profile_id'] = @profile.id
                datatables[table_no]['email_type_id'] = item 
                datatables[table_no]['created_by'] = @excel_upload.updated_by
                begin
                  EmailAddress.create(datatables[table_no])
                rescue
                  logfile.puts "Email save NOT successful" + uin
                  @excel_upload.no_errors += 1
                  @excel_upload.notes += "Email save NOT successful:" + uin + "<br>"
                end  
              end # if @email
            elsif tname.include? "address"
              item = @ikeytables[table_no][0]
              @address = Address.find(:first, :conditions => ["profile_id = ? AND address_type_id = ?", @profile.id, item])
              if @address
                begin
                  @address.update_attributes(datatables[table_no])
                rescue
                  logfile.puts "Address update NOT successful" + uin
                  @excel_upload.no_errors += 1
                  @excel_upload.notes += "Address update NOT successful:" + uin + "<br>"
                end
              else
           datatables[table_no]['profile_id'] = @profile.id
           datatables[table_no]['address_type_id'] = item 
           datatables[table_no]['created_by'] = @excel_upload.updated_by
                begin
                  Address.create(datatables[table_no])
                rescue
                  logfile.puts "Address save NOT successful" + uin
                  @excel_upload.no_errors += 1
                  @excel_upload.notes += "Address save NOT successful:" + uin + "<br>"
                end  
              end # if @address
            elsif tname.include? "phone"
              item = @ikeytables[table_no][0]
              RAILS_DEFAULT_LOGGER.info "start phone processing"
              @phone = PhoneNumber.find(:first, :conditions => ["profile_id = ? AND phone_type_id = ?", @profile.id, item])
              if @phone
                begin
                  @phone.update_attributes(datatables[table_no])
                rescue
                  @excel_upload.no_errors += 1
                  @excel_upload.notes += "Phone update NOT successful:" + uin + "<br>"
                  logfile.puts "Phone update NOT successful:" + uin
                end # begin
              else
                datatables[table_no]['profile_id'] = @profile.id
                datatables[table_no]['phone_type_id'] = item 
                datatables[table_no]['created_by'] = @excel_upload.updated_by
                begin
                  PhoneNumber.create(datatables[table_no])
                rescue
                  @excel_upload.no_errors += 1
                  @excel_upload.notes += "Phone save NOT successful:" + uin + "<br>"
                  logfile.puts "Phone update NOT successful:" + uin
                end # begin
              end # if @phone




            else
              logfile.puts "Table name not valid:" + tname
            end # profiles
            table_no += 1
          end

       end # if row_count == 1 / else
      end # FasterCSV.foreach
    end # if !link_file

    logfile.puts "Row Count=" + row_count.to_s
    logfile.puts "Invalid Record Count=" + invalidcount.to_s

    @excel_upload.status = "P"
    if !@excel_upload.save
      logfile.puts "Upload status could not be set to 'P'"
      break
    end

    logfile.puts "end excel_upload"
    logfile.puts Time.now.to_s(:db)
  end   #end of logfile

  RAILS_DEFAULT_LOGGER.info "END excel_upoad:" + Time.now.to_s(:db)
end   #end of task
