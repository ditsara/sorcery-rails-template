# frozen_string_literal: true

# Reset password flow
class User::PasswordsController < ApplicationController
  skip_before_action :require_login

  def new; end

  def create
    @user = User.find_by email: params[:email]
    @user&.generate_reset_password_token!
    UserMailer.reset_password_email(@user).deliver_now
    redirect_to({ action: :new }, flash: { info: 'please check your email' })
  end

  def edit
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated
      nil
    end
  end

  def update
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated
      return
    end

    # the next line makes the password confirmation validation work
    @user.password_confirmation = params[:user][:password_confirmation]
    # the next line clears the temporary token and updates the password
    if @user.change_password(params[:user][:password])
      redirect_to(root_path, notice: 'Password was successfully updated.')
    else
      render action => 'edit'
    end
  end
end
