# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper


  def display_flashes()
    if flash[:notice]
      flash_to_display, level = flash[:notice], 'notice'
    elsif flash[:warning]
      flash_to_display, level = flash[:warning], 'warning'
    elsif flash[:error]
      flash_to_display, level = flash[:error], 'error'
    else
      return
    end
    content_tag 'div', flash_to_display, :id =>"#{level}Explanation"

  end


end
