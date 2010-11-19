module ApplicationHelper
  LOCALES_DIRECTORY = "#{RAILS_ROOT}/config/locales/defaults"

  def available_locales
    Dir["#{LOCALES_DIRECTORY}/*.{rb,yml}"].collect do |locale_file|
      File.basename(File.basename(locale_file, ".rb"), ".yml")
    end.uniq.sort
  end
  
  def domain
    request.domain + ":" + request.port.to_s
  end

end
