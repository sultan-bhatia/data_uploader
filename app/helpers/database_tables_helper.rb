module DatabaseTablesHelper

  def format_row(column)
    html = ""
	if column == "updated_by" || column == "created_by" || column == "updated_at" || column == "created_at"
	elsif column == "id" || column == "person_id"
	elsif column == @table.name.downcase + "_type_id"
	  html = <<-HTML
        <tr>
          <td>&nbsp;#{@table.name} Type&nbsp;</td>
		  <td>&nbsp; #{@tname} &nbsp;</td>
		  <td>&nbsp;
              #{select_tag "data_type_name", options_for_select(@ttype_data),
                      :onchange => remote_function(
                        :before    => "Element.show('spinner')", 
                        :complete  => "Element.hide('spinner')", 
                        :url       => {:action=>'onchange_data_type_name', :only_path => false},
                        :with      => "'data_type_name=' + $('data_type_name').value + '&table_name=' + '#{@table.name}' + '&ttype_name=' + '#{@ttype.name}'")
			  }
		  &nbsp; </td>
		  <td>&nbsp; </td>
        </tr>
	  HTML
    else
	  html = "<tr><td>&nbsp;<span id='#{column}' class='drag_element'>"
	  html += "#{session[:data_type_name]} " if session[:data_type_name] != " "
	  if column == "name"
		html += "#{@table.name.humanize}"
	  else
		html += "#{column.humanize}"
	  end
	  html += "</span>&nbsp;</td>"
	  html += "<td>&nbsp;&nbsp;#{@tname}&nbsp;&nbsp;</td>"
	  html += "<td>&nbsp;&nbsp;#{column}&nbsp;&nbsp;</td>"
	  html += "<td align='center'>#{link_to_remote 'map', :url => {:controller => :data_columns, :action => :map_field, :app_table => @tname, :app_column => column}}</td>"
	  html += "</tr>"
	  html += "#{draggable_element(column, :revert=>true, :ghosting=>true, :scroll=>'window')}"
	end
	return html
  end


end
