# File config/initializers/site_config.rb

    $TABLE_ARR = []
    $TYPE_TABLES = []
    ActiveRecord::Base.connection.tables.each do |table_name|
      y = true
      ["upload_templates", "data_columns", "schema", "migration", "session"].each{|x|
        y = false if table_name.include? x
      }
      if y
        class_name = table_name.split('_').collect { |word| word.capitalize }.join.singularize
         if table_name.include? "type"
           $TYPE_TABLES << klass = Object.const_get(class_name)
         else
           $TABLE_ARR << klass = Object.const_get(class_name)
         end
      end
    end

