class SessionsController < ApplicationController
  def new
  end

  def create
    player = Player.find_by_email(params[:session][:email].downcase)
    if player && player.authenticate(params[:session][:password])
      sign_in player
      redirect_back_or root_url
    else
      flash.now[:error] = 'Invalid email/password combination' 
      render 'new'
    end
  end

  def destroy
    sign_out
    forget_location
    redirect_to root_url
  end
end
