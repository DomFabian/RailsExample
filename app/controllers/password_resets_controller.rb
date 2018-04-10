class PasswordResetsController < ApplicationController
  before_action :get_user,         only: [:edit, :update]
  before_action :valid_user,       only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]  # saves from expired reset token
  
  def new
  end

def create
  @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user  # (exists)
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'  # have the user try again
    end
end

  def edit
  end
  
  def update
    if params[:user][:password].empty?            # saves from blank new password and confirmation
      @user.errors.add(:password, "Can't be empty")
      render 'edit'
    elsif @user.update_attributes(user_params)     # successful password reset
      log_in @user
      @user.update_attribute(:reset_digest, nil)   # protect against someone hitting back button to modify!
      flash[:success] = "Password has been reset."
      redirect_to @user
    else                                          # saves from invalid new password
      render 'edit'
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
  
  # before filters
  
  def get_user
    @user = User.find_by(email: params[:email])
  end
  
  # confirms a valid user
  def valid_user
    unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
      redirect_to root_url
    end
  end
  
  # checks expiration of reset token (limit two hours)
  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = "Password reset has expired."
      redirect_to new_password_reset_url
    end
  end
  
end
