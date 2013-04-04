require 'spec_helper'

describe "EmailConfirmations" do
  it "makes player activated when remember token matches" do
    player = FactoryGirl.create(:player, activated: false, activate_token: "something", activate_sent_at: 1.hour.ago)
    visit signup_confirmation_path(player.activate_token)
    player.reload.should be_activated
    page.should have_content("Email address confirmed")
  end
  
  it "reports when activate token has expired" do
    player = FactoryGirl.create(:player, activated: false, activate_token: "something", activate_sent_at: 31.days.ago)
    visit signup_confirmation_path(player.activate_token)
    player.reload.should_not be_activated
    page.should have_content("Account activation link has expired")
  end

  it "raises record not found when remember token is invalid" do
    lambda {
      visit signup_confirmation_path("invalid")
    }.should raise_exception(ActiveRecord::RecordNotFound)
  end
end
