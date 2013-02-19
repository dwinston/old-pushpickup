require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe 'signin' do
    before { visit signin_path }
    it { should have_selector 'h1', text: 'Sign in' }
    it { should have_selector 'title', text: 'Sign in' }

    describe 'with invalid information' do
      before { click_button 'Sign in' }

      it { should have_selector 'title', text: 'Sign in' }
      it { should have_error_message 'Invalid' } # see spec/support/utilities.rb

      describe 'after visiting another page' do
        before { click_link 'Home' }
        it { should_not have_error_message '' }
      end
    end

    describe 'with valid information' do
      let(:player) { FactoryGirl.create(:player) }
      before { valid_signin(player) } # see spec/support/utilities.rb

      it { should have_selector 'title', text: player.name }
      it { should have_link 'Profile', href: player_path(player) }
      it { should have_link 'Sign out', href: signout_path }
      it { should_not have_link 'Sign in', href: signin_path }

      describe 'followed by signout' do
        before { click_link 'Sign out' }
        it { should have_link 'Sign in' }
      end
    end
  end
end
