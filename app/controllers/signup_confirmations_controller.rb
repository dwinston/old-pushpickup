class SignupConfirmationsController < ApplicationController
  def show
    @player = Player.find_by_activate_token!(params[:id])
    if @player.activate_sent_at < 30.days.ago
      redirect_to root_path, alert: "Account activation link has expired."
    else 
      @player.update_attribute(:activated, true)
      sign_in @player
      redirect_to root_path, flash: {success: "Email address confirmed. Now your availabilities can help create games!"}
    end
  end
end
