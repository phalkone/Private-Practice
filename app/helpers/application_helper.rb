module ApplicationHelper
  LOCALES_DIRECTORY = "#{::Rails.root.to_s}/config/locales/defaults"

  def available_locales
    Dir["#{LOCALES_DIRECTORY}/*.{rb,yml}"].collect do |locale_file|
      File.basename(File.basename(locale_file, ".rb"), ".yml")
    end.uniq.sort
  end
  
  def domain
    # FIXME for production mode
    request.host.split(".")[1] + "." + request.host.split(".").last + ":" + request.port.to_s
  end

  def title
    base_title = t("txt.private") + " " + t("txt.practice")
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end
  
  def menu_active
    @menu_active ||= controller.controller_name
  end

end
