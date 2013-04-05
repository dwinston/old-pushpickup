require "spec_helper"

describe PlayerMailer do
  describe "password_reset" do
    let(:player) { FactoryGirl.create(:player, password_reset_token: "anything") }
    let(:mail) { PlayerMailer.password_reset(player) }

    it "sends player password reset url" do
      mail.subject.should include("Password Reset")
      mail.to.should eq([player.email])
      mail.from.should eq(["dwinst@gmail.com"])
      mail.body.encoded.should match(edit_password_reset_path(player.password_reset_token))
    end
  end

  describe "email_confirmation" do
    let(:player) { FactoryGirl.create(:player, activated: false, email_confirmation_token: "anything") }
    let(:mail) { PlayerMailer.email_confirmation(player) }

    it "sends player email confirmation url" do
      mail.subject.should include("Email Confirmation")
      mail.to.should eq([player.email])
      mail.from.should eq(["dwinst@gmail.com"])
      mail.body.encoded.should match(email_confirmation_path(player.email_confirmation_token))
    end
  end

  describe "game_notification" do
    let(:player_emails) { FactoryGirl.create_list(:player, 14).map(&:email) }
    let(:field) { FactoryGirl.create(:field) }
    let(:start_time) { Time.zone.now.beginning_of_hour + 3.hours }
    let(:duration) { 90 }
    let(:mail) { PlayerMailer.game_notification(player_emails, field, start_time, duration) }

    it "sends players game notification that includes field name, start time, and duration" do
      mail.subject.should include("Game On!")
      mail.bcc.should include(*player_emails)
      mail.body.should include(field.name, 
                               start_time.to_s(:weekday_and_ordinal),
                               distance_of_time_in_words(start_time, start_time + duration.minutes))
      mail.from.should eq(["dwinst@gmail.com"])
      #mail.body.encoded.should match(field_path(field))
    end
  end
end
