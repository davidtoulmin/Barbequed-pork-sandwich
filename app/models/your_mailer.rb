class YourMailer < ActionMailer::Base
  def email_name(user)
    @user = user
    mail subject: 'Your News Feed!',
         to: user.email,
         from: 'NewsFeed@newsdigest.com'
  end
end
