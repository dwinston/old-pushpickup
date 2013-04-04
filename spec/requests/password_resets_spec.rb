require 'spec_helper'

describe "PasswordResets" do

  it 'emails player when requesting password reset' do
    player = FactoryGirl.create(:player)
    visit signin_path
    click_link "password"
    fill_in "Email", with: player.email
    click_button "Reset Password"
    current_path.should eq(root_path)
    page.should have_content("Email sent")
    last_email.to.should include(player.email)
  end

  it 'does not email invalid player when requesting password reset' do
    visit signin_path
    click_link "password"
    fill_in "Email", with: "nobody@example.com"
    click_button "Reset Password"
    current_path.should eq(root_path)
    page.should have_content("Email sent")
    last_email.should be_nil
  end

  it "updates the player password when confirmation matches" do
    player = FactoryGirl.create(:player, password_reset_token: "something", password_reset_sent_at: 1.hour.ago)
    visit edit_password_reset_path(player.password_reset_token)
    fill_in "Password", with: "foobar"
    click_button "Update password"
    page.should have_content("Password doesn't match confirmation")
    fill_in "Password", with: "foobar"
    fill_in "Confirm password", with: "foobar"
    click_button "Update password"
    page.should have_content("Password has been reset")
  end

  it "reports when password token has expired" do
    player = FactoryGirl.create(:player, password_reset_token: "something", password_reset_sent_at: 5.hours.ago)
    visit edit_password_reset_path(player.password_reset_token)
    fill_in "Password", with: "foobar"
    fill_in "Confirm password", with: "foobar"
    click_button "Update password"
    page.should have_content("Password reset has expired")
  end

  it "raises record not found when password token is invalid" do
    lambda {
      visit edit_password_reset_path("invalid")
    }.should raise_exception(ActiveRecord::RecordNotFound)
  end
end
