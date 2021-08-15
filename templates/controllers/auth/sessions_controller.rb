# frozen_string_literal: true

# User login / logout; user "Sign In/Out" in user text
class Auth::SessionsController < ApplicationController
  skip_before_action :require_login

  # login form
  def new
    redirect_to('/', notice: 'Already signed in') if current_user
    @user = User.new
  end

  # login submission
  def create
    @user = login(login_params[:email], login_params[:password])
    if @user
      redirect_back_or_to(root_path, notice: 'Sign in successful')
    else
      @user ||= User.new
      flash.now[:alert] = 'Sign in failed'
      render action: 'new'
    end
  end

  # logout
  def destroy
    logout
    redirect_to(root_path, notice: 'Signed out')
  end

  private

  def login_params
    params.require(:user).permit(:email, :password)
  end
end
