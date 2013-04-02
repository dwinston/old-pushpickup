class PlayerMailer < ActionMailer::Base
  default from: "dwinst@gmail.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.player_mailer.signup_confirmation.subject
  #
  def signup_confirmation(player)
    @player = player

    mail to: player.email, subject: '[Push Pickup] Sign Up Confirmation'
  end
end
