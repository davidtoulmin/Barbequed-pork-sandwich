# app/mailers/user_mailer.rb

class UserMailer < BaseMandrillMailer
  def welcome(user)
    subject = "Welcome to our awesome app!"
    merge_vars = {
      "FIRST_NAME" => user.first_name
    }
    body = mandrill_template("welcome", merge_vars)

    send_mail(user.email, subject, body)
  end
end