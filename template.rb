

def apply_template!
  gem 'sorcery'

  # write each of our template files into the appropriate location
  

  file "app/mailers/user_mailer.rb",
    __file_templates["templates/mailers/user_mailer.rb"]

  

  file "app/views/user_mailer/reset_password_email.text.erb",
    __file_templates["templates/views/user_mailer/reset_password_email.text.erb"]

  

  file "app/views/user/passwords/new.html.erb",
    __file_templates["templates/views/user/passwords/new.html.erb"]

  

  file "app/views/user/passwords/edit.html.erb",
    __file_templates["templates/views/user/passwords/edit.html.erb"]

  

  file "app/views/user/registrations/new.html.erb",
    __file_templates["templates/views/user/registrations/new.html.erb"]

  

  file "app/views/user/sessions/new.html.erb",
    __file_templates["templates/views/user/sessions/new.html.erb"]

  

  file "app/controllers/user/passwords_controller.rb",
    __file_templates["templates/controllers/user/passwords_controller.rb"]

  

  file "app/controllers/user/sessions_controller.rb",
    __file_templates["templates/controllers/user/sessions_controller.rb"]

  

  file "app/controllers/user/registrations_controller.rb",
    __file_templates["templates/controllers/user/registrations_controller.rb"]

  

  route <<~EOF
    namespace :user do
      resource :registrations, only: %i[new create]
      resource :sessions, only: %i[new create destroy]
      resource :profiles, only: %i[show update]
      resources :passwords, only: %i[new create edit update]
    end
  EOF

  after_bundle do
    generate("sorcery:install", "remember_me", "reset_password")
  end
end

# generated - read all the files in `templates/` into one big hash
# (of filename => contents); this packages everything into the final
# `template.rb` file so we can be agnostic to whether we're accessing the
# template locally, or git, etc.
def __file_templates
  return @__file_templates_data if @__file_templates_data

  @__file_templates_data = {}
  

  @__file_templates_data["templates/mailers/user_mailer.rb"] = <<~EOF

# frozen_string_literal: true

# user related mails
class UserMailer < ApplicationMailer
  default from: 'from@example.com'
  layout 'mailer'

  def reset_password_email(user)
    @user = User.find user.id
    @url  = edit_user_password_url(@user.reset_password_token)
    mail(to: @user.email, subject: 'Your password has been reset')
  end
end


  EOF

  

  @__file_templates_data["templates/views/user_mailer/reset_password_email.text.erb"] = <<~EOF

Hello, <%= @user.email %>
===============================================

You have requested to reset your password.

To choose a new password, just follow this link: <%= @url %>

Have a great day!


  EOF

  

  @__file_templates_data["templates/views/user/passwords/new.html.erb"] = <<~EOF

<h1>forgot password</h1>
<%= form_with url: { action: :create } do |f| %>
  <fieldset>
    <%= f.label :email %>
    <%= f.email_field :email %>
  </fieldset>
  <%= f.submit %>
<% end %>


  EOF

  

  @__file_templates_data["templates/views/user/passwords/edit.html.erb"] = <<~EOF

<h1>set new password</h1>
<%= form_with model: @user, url: { action: :update } do |f| %>
  <fieldset>
    <%= f.label :password %>
    <%= f.password_field :password %>
  </fieldset>
  <fieldset>
    <%= f.label :password_confirmation %>
    <%= f.password_field :password_confirmation %>
  </fieldset>
  <%= f.submit %>
<% end %>


  EOF

  

  @__file_templates_data["templates/views/user/registrations/new.html.erb"] = <<~EOF

<h1>sign up</h1>
<%= form_with model: @user, url: { action: :create } do |f| %>
  <fieldset>
    <%= f.label :email %>
    <%= f.email_field :email %>
  </fieldset>
  <fieldset>
    <%= f.label :password %>
    <%= f.password_field :password %>
  </fieldset>
  <fieldset>
    <%= f.label :password_confirmation %>
    <%= f.password_field :password_confirmation %>
  </fieldset>
  <%= f.submit %>
<% end %>


  EOF

  

  @__file_templates_data["templates/views/user/sessions/new.html.erb"] = <<~EOF

<h1>sign in</h1>
<%= form_with model: @user, url: { action: :create } do |f| %>
  <fieldset>
    <%= f.label :email %>
    <%= f.text_field :email %>
  </fieldset>
  <fieldset>
    <%= f.label :password %>
    <%= f.password_field :password %>
  </fieldset>
  <%= f.submit "Login" %>
<% end %>


  EOF

  

  @__file_templates_data["templates/controllers/user/passwords_controller.rb"] = <<~EOF

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


  EOF

  

  @__file_templates_data["templates/controllers/user/sessions_controller.rb"] = <<~EOF

# frozen_string_literal: true

# User login / logout; user "Sign In/Out" in user text
class User::SessionsController < ApplicationController
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


  EOF

  

  @__file_templates_data["templates/controllers/user/registrations_controller.rb"] = <<~EOF

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


  EOF

  
end

apply_template!
