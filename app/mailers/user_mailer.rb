class UserMailer < ActionMailer::Base
  default :from => "webmaster@app.local"

  def password_reset_instructions(user)
    @user = user
    @url  = edit_password_reset_url(user.perishable_token, :host => "nl.app.local:3000")
    mail(:to => user.email,
      :subject => t("password_reset_instructions.title"))
  end

end
