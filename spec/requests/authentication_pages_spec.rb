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
      before { sign_in player } # see spec/support/utilities.rb

      it { should have_selector 'title', text: player.name }
      it { should have_link 'Profile', href: player_path(player) }
      it { should have_link 'Settings', href: edit_player_path(player) }
      it { should have_link 'Sign out', href: signout_path }
      it { should_not have_link 'Sign in', href: signin_path }

      describe 'followed by signout' do
        before { click_link 'Sign out' }
        it { should have_link 'Sign in' }
      end
    end
  end

  describe 'authorization' do

    describe 'for non-signed-in players' do
      let(:player) { FactoryGirl.create(:player) }

      describe 'in the Players controller' do

        describe 'visiting the edit page' do
          before { visit edit_player_path(player) }
          it { should have_selector 'title', text: 'Sign in' }
        end

        describe 'submitting to the update action' do
          before { put player_path(player) }
          specify { response.should redirect_to(signin_path) }
        end
      end
    end
  end
end
