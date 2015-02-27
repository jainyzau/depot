class SessionsController < ApplicationController
  skip_before_action :authorize

  def new
    unless session[:user_id].nil?
        user = User.find(session[:user_id])
        redirect_to admin_url, notice: "You are already loged in as #{user.name}."
        return
    end
  end

  def create
    unless session[:user_id].nil?
        user = User.find(session[:user_id])
        redirect_to admin_url, notice: "You are already loged in as #{user.name}."
        return
    end

    user = User.find_by(name: params[:name])
    if user and user.authenticate(params[:password])
        session[:user_id] = user.id
        redirect_to admin_url
    else
        redirect_to login_url, alert: "Invalid user/password combination"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to store_url, notice: "Logged out"
  end
end
