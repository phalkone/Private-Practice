class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale

  include UserSessionsHelper
  include CalendarHelper
  include BookingsHelper
  
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
  
  def default_url_options(options={})
    { :locale => I18n.locale }
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
