# frozen_string_literal: true

# user related mails
class AuthMailer < ApplicationMailer
  default from: 'from@example.com'
  layout 'mailer'

  def reset_password_email(user)
    @user = User.find user.id
    @url  = edit_user_password_url(@user.reset_password_token)
    mail(to: @user.email, subject: 'Your password has been reset')
  end
end
