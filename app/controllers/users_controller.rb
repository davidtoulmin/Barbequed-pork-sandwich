class UsersController < ApplicationController
  before_action :authenticate_user, only: [:show, :edit, :destroy, :update]
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all.reverse
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/edit
  def edit
  end

  # user /users
  # user /users.json
  def create
    # Create user with given input, and save to the db, redirecting as appropriate
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        log_in @user
        format.html { redirect_to articles_path, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    # Update user with given input, and save to the db, redirecting as appropriate
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to articles_path, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    # Delete user from the db, redirecting as appropriate
    log_out
    @user.destroy
    respond_to do |format|
      format.html { redirect_to login_path, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  # Method responsible for sending the emails in response to the request
  # admin/email.
  def email
     # Finds a list of all users that are opted in for email newsfeeds
     User.where(opt_in: true).find_each do |user|
      # For each user, send the email called 'email_name'
      # to that user and deliver it now.
      # The email that will be sent is stored as a view
      # your_mailer views, called email_name.html.erb
      # this particular view shows the structure of the email
      # that will be sent.
      # The logic for which articles to be sent to each user is stored
      # in this embedded ruby html file.
      YourMailer.email_name(user).deliver
      # Update the last_emailed user attribute to avoid
      # the clash of being sent articles you've been emailed
      # before.
      user.update_attribute(:last_emailed, DateTime.now)
     end
     redirect_to articles_path

  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = current_user
  end

  def check_valid
    redirect_to articles_path unless @user == current_user
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :bio, :username, :password, :password_confirmation, :interest_list, :opt_in, :last_emailed)
  end
end
