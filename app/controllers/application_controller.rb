class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Include our session helper
  include SessionsHelper

  def authenticate_user
    unless current_user
      redirect_to login_path 
    end
  end

  def navigate_back
    redirect_to :back
  end
end
