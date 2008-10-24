class SessionsController < ApplicationController

  layout "1col"

  def new
  end

  def create
    if params[:session]
      user = User.authenticate(params[:session][:login], params[:session][:password])
    end
    if user
      login_user(user)
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
end
