# This class is responsible for generating an email that appears like the view
# your_mailer depicts. It is a subclass of the Action Mailer class, and is using
# the Mandrill mailer service under my API license.
# Due to my account being free, there are several restictrions on the license
# such as only 25 emails per hour and a total of 2000 free emails on the license.
#
# Author::    Leonidas Skopilianos (skl@student.unimelb.edu.au)
# Copyright:: Copyright (c) 2015 Leonidas Skopilianos
# Completed in Partial Completion of SWEN30006
# At: The University Of Melbourne
#
#
class YourMailer < ActionMailer::Base
  def email_name(user)
    # Creates an instance of the user this email will be sent to.
    @user = user
    # generates the mail with specific subjects, who it is from and to whom it is going.
    # This will also render the view mentioned in the header of this file as the email
    # contents that will be sent to the user.email.
    mail subject: 'Your News Feed!',
         to: user.email,
         from: 'NewsFeed@newsdigest.com'
  end
end
