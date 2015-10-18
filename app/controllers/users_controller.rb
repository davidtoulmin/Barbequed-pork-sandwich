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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = current_user
    end

    def check_valid
      unless @user==current_user
        redirect_to articles_path
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :bio, :username, :password, :password_confirmation, :interest_list,:opt_in,:last_emailed)
    end
end
