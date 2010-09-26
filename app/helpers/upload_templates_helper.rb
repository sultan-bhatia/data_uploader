module UploadTemplatesHelper

  def template_info_data
    html = ""
    html += "Template: <b>#{@upload_template.name}</b>" if @upload_template.name
    html += " | Input File: <b>#{@upload_template.document.file.filename}</b>" if @upload_template.document?
	(@upload_template.status == "2")? stts = "Processed" : stts = "Not Processed Yet"
	html += " | Status: <b>#{stts}</b>"
	html += " | Process Date: <b>#{@upload_template.updated_at}</b>" if @upload_template.status == "2"
	return html
  end

  def template_info_options
	if @upload_template.status != "2"
      html = "<b>#{link_to_remote 'Process File', :url => {:controller => :upload_templates, :action => :process_file, :id => @upload_template.id}}</b>&nbsp"
	else
      html = "#{link_to 'Show', :controller => :upload_templates, :action => :show, :id => @upload_template.id}&nbsp"
	end
    html += "&nbsp;&nbsp;#{link_to 'Exit', :controller => :upload_templates, :action => :index}"
	return html
  end


end
