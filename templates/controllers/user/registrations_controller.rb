# frozen_string_literal: true

# User registration and password resets
class User::RegistrationsController < ApplicationController
  skip_before_action :require_login

  # Sign up form
  def new
    @user = User.new
  end

  # Sign up submission
  def create
    @user = User.new new_user_params

    if @user.valid?
      @user.save
      redirect_to '/', flash: { info: 'User created' }
    else
      flash.now.alert = @user.errors.messages
      render :new
    end
  end

  # Recover password form
  def edit; end

  # Recover password submission
  def update; end

  private

  def new_user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
