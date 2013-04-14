require 'spec_helper'

describe "EmailConfirmations" do

  it 'after signup, player is inactive and sent an email confirmation' do
    player = FactoryGirl.build(:player)
    sign_up player
    player = Player.find_by_email(player.email)
    player.should_not be_activated
    last_email.to.should include(player.email)
  end

  it 'inactivates and emails player when changing email address' do
    player = FactoryGirl.create(:player)
    sign_in player
    click_link "your settings"
    fill_in "Email", with: "player@example.com"
    click_button "Save changes"
    current_path.should eq(root_path)
    page.should have_content("Email sent")
    player.reload.should_not be_activated
    last_email.to.should include(player.email)
  end

  it "activates player when confirmation matches" do
    player = FactoryGirl.create(:player, activated: false, email_confirmation_token: "something", email_confirmation_sent_at: 1.hour.ago)
    visit email_confirmation_path(player.email_confirmation_token)
    player.reload.should be_activated
    page.should have_content("Email address confirmed")
  end
  
  it "reports when email confirmation token has expired" do
    player = FactoryGirl.create(:player, activated: false, email_confirmation_token: "something", email_confirmation_sent_at: 5.hours.ago)
    visit email_confirmation_path(player.email_confirmation_token)
    player.reload.should_not be_activated
    page.should have_content("Email confirmation has expired")
  end

  it "raises record not found when remember token is invalid" do
    lambda {
      visit email_confirmation_path("invalid")
    }.should raise_exception(ActiveRecord::RecordNotFound)
  end
end
