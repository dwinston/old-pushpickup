class SignupConfirmationsController < ApplicationController
  def show
    @player = Player.find_by_remember_token!(params[:id])
    @player.refresh_remember_token
    @player.toggle!(:activated)
    sign_in @player.reload
    redirect_to root_path, flash: {success: "Email address confirmed. Welcome to Push Pickup!"}
  end
end
