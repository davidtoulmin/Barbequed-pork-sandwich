class YourMailer < ActionMailer::Base
  def email_name user
    @user = user
    mail :subject => "Your Newsfeed!",
         :to      => user.email,
         :from    => "Newsdigest"
  end
end