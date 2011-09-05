class UserMailer < ActionMailer::Base
  default :from => "webmaster@app.local"
  # TODO Set real host for production
  default_url_options[:host] = "localhost:3000"
  
  def contact_message(message)
    @url = message_url(message, :locale => I18n.locale.to_s)
    mail(:from => message.email, :to => message.user.email,
      :subject => message.subject) do |format|
        format.text
      end
  end
  
  def email_confirmation_instructions(user)
    @user = user
    @url  = email_confirmation_url(:id => user.perishable_token, :locale => I18n.locale.to_s)
    @url2 = new_email_confirmation_url(:email => user.email, :locale => I18n.locale.to_s)
    mail(:to => user.email,
      :subject => t("email_confirmation_instructions.title"))  do |format|
        format.html
        format.text
      end
  end

  def password_reset_instructions(user)
    @user = user
    @url  = edit_password_reset_url(user.perishable_token, :locale => I18n.locale.to_s)
    mail(:to => user.email,
      :subject => t("password_reset_instructions.title")) do |format|
        format.html
        format.text
      end
  end

end
