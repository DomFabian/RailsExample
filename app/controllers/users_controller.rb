class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  
  def index
    @users = User.where(activated: true).paginate(page: params[:page]) # show only the first page of (not all)
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)  # see below private method
    if @user.save  # is a successful new user
      @user.send_activation_email
      flash[:info] = "An email has been sent to " + @user.email + ". Click the enclosed link the activate your new account."
      redirect_to root_url
    else
      render 'new'
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
    
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile successfully updated"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User successfully deleted."
    redirect_to users_url
  end
  
  private
    
    # confirms an admin user
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
    def user_params # only let these things be passed into the form!
     params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
   
   # before filters
   
   # checks to see if a user is logged in
   def logged_in_user
     unless logged_in?
       store_location
       flash[:danger] = "Please log in"
       redirect_to login_url
     end
   end
   
   def correct_user
     @user = User.find(params[:id])
     redirect_to(root_url) unless current_user?(@user)
   end
  
end
