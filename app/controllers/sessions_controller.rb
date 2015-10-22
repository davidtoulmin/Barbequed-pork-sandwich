class SessionsController < ApplicationController

  # Before actions to check paramters
  before_action :check_params, only: [:login]
  before_action :authenticate_user, only: [:logout]

  def unauth
  end

  # Find a user with the password and username pair, log in that user if they exist
  def login
    # Find a user with params
    user = User.authenticate(@credentials[:password], @credentials[:username])
    if user
      # Save them in the session
      log_in user
      # Redirect to articles page
      redirect_to articles_path
  else
    redirect_to :back
  end
  end

  # Log out the user in the session and redirect to the unauth thing
  def logout
    log_out
    redirect_to login_path
  end

  def email
     #UserMailer.welcome(current_user).deliver_now
     User.where(opt_in: true).find_each do |user|
      #user.update_attribute(:last_emailed, DateTime.now - 200000)
      YourMailer.email_name(user).deliver
      user.update_attribute(:last_emailed, DateTime.now)
     end
     redirect_to articles_path
     #@users = User.find_by(opt_in: true)
     #@users.each do |user|
      #  YourMailer.email_name(user).deliver
      #  redirect_to articles_path
     #end
  end

  # Private controller methods
  private
  def check_params
    params.require(:credentials).permit(:password, :username)
    @credentials = params[:credentials]
  end

end
