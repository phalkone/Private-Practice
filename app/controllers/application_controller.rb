class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale

  def set_locale 
    I18n.locale = extract_locale_from_subdomain
  end

  def extract_locale_from_subdomain
    parsed_locale = request.subdomains.first
    if !parsed_locale.nil?
      I18n.available_locales.include?(parsed_locale.to_sym) ? parsed_locale  : nil
    end
  end
end
