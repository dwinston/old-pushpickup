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
end