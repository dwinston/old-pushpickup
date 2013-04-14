class EmailConfirmationsController < ApplicationController
  def show
    @player = Player.find_by_email_confirmation_token!(params[:id])
    if @player.email_confirmation_sent_at < 2.hours.ago
      redirect_to root_path, alert: "Email confirmation has expired."
    else
      @player.update_attribute(:activated, true)
      sign_in @player
      redirect_to root_path, flash: {success: "Email address confirmed."}
    end
  end
end
