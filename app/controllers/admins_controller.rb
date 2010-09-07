class AdminsController < ApplicationController

  before_filter :find_table_class, :except => :index

  def index

    render :update do |page|
      page.replace_html "main-content", :partial => "index"
    end

  end

  def new

    @form_data = @table.new
    render :update do |page|
      page.replace_html @table.name + "-form", :partial => "form", :locals => {:button_label => "Add", :next_action => :create}
    end

  end
  
  def edit

    @form_data = @table.find(params[:id])
    render :update do |page|
      page.replace_html @table.name + "-form", :partial => "form", :locals => {:button_label => "Update", :next_action => :update}
    end

  end

  def create
    
    @table_row = @table.new(params[:form_data])
    @table_row.save

    render :update do |page|
      page.replace_html @table.name + "-form", :partial => "list"
    end

  end  
  
  def update
    
    @table_row = @table.find(params[:id])
    @table_row.update_attributes(params[:form_data])

    render :update do |page|
      page.replace_html @table.name + "-form", :partial => "list"
    end
    
  end  
  
  def destroy

    @table_row = @table.find(params[:id])
    @table_row.destroy

    render :update do |page|
      page.replace_html @table.name + "-form", :partial => "list"
    end

  end  
  
  def cancel
    
    render :update do |page|
      page.replace_html @table.name + "-form", :partial => "list"
    end

  end  

private

  def find_table_class
    
    @table = Object.const_get(params[:table_name])

  end
  
end
