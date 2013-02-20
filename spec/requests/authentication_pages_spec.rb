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

      it { should have_link 'Players', href: players_path }
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

      describe 'when attempting to visit a protected page' do
        before do
          visit edit_player_path(player)
          fill_in 'Email',    with: player.email
          fill_in 'Password', with: player.password
          click_button 'Sign in'
        end

        describe 'after signin in' do
          it 'should render the desired protected page' do
            page.should have_selector 'title', text: 'Edit player'
          end
        end

        describe 'when signing in again' do
          before do
            delete signout_path
            visit signin_path
            fill_in 'Email', with: player.email
            fill_in 'Password', with: player.password
            click_button 'Sign in'
          end

          it 'shoulds render the default (profile) page' do
            page.should have_selector 'title', text: player.name
          end
        end
      end

      describe 'in the Players controller' do

        describe 'visiting the edit page' do
          before { visit edit_player_path(player) }
          it { should have_selector 'title', text: 'Sign in' }
        end

        describe 'submitting to the update action' do
          before { put player_path(player) }
          specify { response.should redirect_to(signin_path) }
        end

        describe 'visiting the player index action' do
          before { visit players_path }
          it { should have_selector 'title', text: 'Sign in' }
        end
      end
    end

    describe 'as wrong player' do
      let(:player) { FactoryGirl.create(:player) }
      let(:wrong_player) { FactoryGirl.create(:player, email: 'wrong@example.com') }
      before { sign_in player }

      describe 'visiting Players#edit page' do
        before { visit edit_player_path(wrong_player) }
        it { should_not have_selector 'title', text: full_title('Edit player') }
      end

      describe 'submitting a PUT request to the Players#update action' do
        before { put player_path(wrong_player) }
        specify { response.should redirect_to(root_path) }
      end
    end

    describe 'as non-admin player' do
      let(:player) { FactoryGirl.create(:player) }
      let(:non_admin) { FactoryGirl.create(:player) }

      before { sign_in non_admin }

      describe "submitting a DELETE request to the Players#destroy action" do
        before { delete player_path(player) }
        specify { response.should redirect_to(root_path) }
      end
    end

    describe 'as admin player' do
      let(:admin) { FactoryGirl.create(:admin) }
      before { sign_in admin }
      describe 'cannot destroy self' do
        before { delete player_path(admin) }
        specify { response.should redirect_to(root_path) }
      end
    end
  end
end
