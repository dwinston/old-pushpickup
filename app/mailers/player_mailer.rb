class PlayerMailer < ActionMailer::Base
  default from: "dwinst@gmail.com"
  
  def subject_preface 
    "[Push Pickup] "
  end

  def signup_confirmation(player)
    @player = player
    mail to: player.email, subject: subject_preface + "Sign Up Confirmation"
  end

  def password_reset(player)
    @player = player
    mail to: player.email, subject: subject_preface + "Password Reset"
  end

  def game_notification(player_emails, field, start_time, duration)
    @field, @start_time, @duration = field, start_time, duration
    mail bcc: player_emails, subject: subject_preface + "Game On!"
  end
end
