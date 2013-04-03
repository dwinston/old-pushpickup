class PlayerMailer < ActionMailer::Base
  default from: "dwinst@gmail.com"

  def signup_confirmation(player)
    @player = player
    mail to: player.email, subject: "[Push Pickup] Sign Up Confirmation"
  end

  def password_reset(player)
    @player = player
    mail to: player.email, subject: "[Push Pickup] Password Reset"
  end
end
