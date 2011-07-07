class UserMailer < ActionMailer::Base
  default :from => "webmaster@app.local"
  
  def email_confirmation_instructions(user)
    @user = user
    @url  = email_confirmation_url(user.perishable_token, :host => I18n.locale.to_s + ".app.local:3000")
    @url2 = new_email_confirmation_url(:host => I18n.locale.to_s + ".app.local:3000")
    #TODO change test e-mail
    mail(:to => user.email,
      :subject => t("email_confirmation_instructions.title"))  do |format|
        format.html
        format.text
      end
  end

  def password_reset_instructions(user)
    @user = user
    @url  = edit_password_reset_url(user.perishable_token, :host => I18n.locale.to_s + ".app.local:3000")
    mail(:to => user.email,
      :subject => t("password_reset_instructions.title")) do |format|
        format.html
        format.text
      end
  end

end
