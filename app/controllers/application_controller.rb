class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale

  include UserSessionsHelper
  include CalendarHelper
  include BookingsHelper
  
  def set_locale 
    I18n.locale = extract_locale_from_subdomain
  end

  def extract_locale_from_subdomain
    parsed_locale = request.subdomains.first
    if !parsed_locale.nil?
      I18n.available_locales.include?(parsed_locale.to_sym) ? parsed_locale  : nil
    end
  end

  protected
    
    def redirect_back_or_default(default = root_path)
      unless request.env['HTTP_REFERER']
        redirect_to default
      else
        redirect_to request.env['HTTP_REFERER']
      end
    end
    
end
