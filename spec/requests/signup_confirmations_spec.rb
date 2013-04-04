require 'spec_helper'

describe "SignupConfirmations" do
  it "makes player activated when remember token matches" do
    player = FactoryGirl.create(:player, activated: false)
    visit signup_confirmation_path(player.remember_token)
    player.reload.should be_activated
    page.should have_content("Email address confirmed")
  end

  it "raises record not found when remember token is invalid" do
    lambda {
      visit signup_confirmation_path("invalid")
    }.should raise_exception(ActiveRecord::RecordNotFound)
  end
end
