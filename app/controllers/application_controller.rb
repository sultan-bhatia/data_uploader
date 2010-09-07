# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

#  rescue_from Exception, :with => :generic_error

private

  def generic_error
    render :update do |page|
      page.replace_html "main-content", :text => "Unidentified problem", :status => 404
    end
  end

end
