class SessionsController < ApplicationController

  self.template_root = "#{RAILS_ROOT}/vendor/plugins/typus/app/views"

  layout "login"

  include TypusHelper

  def create
    if request.post?
      @user = User.authenticate(params[:user])
      if @user
        session[:typus] = @user.id
        flash[:notice] = "Successfully logged in the system."
        redirect_to admin_url
      else
        flash[:error] = "Error! Check your email and password."
        render :action => 'create'
      end
    else
      @user = User.new()
      @user.email = flash[:email]
    end
  end

  def destroy
    session[:typus] = nil
    redirect_to :action => 'create'
  end

  def password_recover
    if request.post?
      @user = User.find_by_email_and_is_admin(params[:user][:email], true)
      unless @user.nil?
        @password = generate_password(8)
        @user.password = @password
        AdminMailer.deliver_password(@user, @password)
        if @user.save
          flash[:email] = params[:user][:email]
          if RAILS_ENV == "development"
            flash[:notice] = "New password is #{@password}"
          else
            flash[:notice] = "New password sent to your inbox."
          end
        end
        redirect_to :action => "create"
      else
        flash[:error] = "Email doesn't exist on the system."
        redirect_to :action => "password_recover"
      end
    end
  end

end