require 'spec_helper'

describe "Player pages" do

  subject { page }

  describe 'signup' do
    before { visit signup_path }
    it { should have_selector 'h1', text: 'Sign up' }
    it { should have_selector 'title', text: full_title('Sign up') }

    let(:submit) {"Create my account"}

    describe 'with invalid information' do
      it 'should not create a player' do
        expect { click_button submit }.not_to change(Player, :count)
      end

      describe 'after submission' do
        before { click_button submit }
        it { should have_selector 'title', text: 'Sign up' }
        it { should have_content 'error' }
      end
    end

    describe 'with valid information' do
      before do
        fill_in 'Name',         with: 'Example Player'
        fill_in 'Email',        with: 'player@example.com'
        fill_in 'Password',     with: 'foobar'
        fill_in 'Confirmation', with: 'foobar'
      end

      it 'should create a player' do
        expect { click_button submit }.to change(Player, :count).by(1)
      end

      describe 'after saving the user' do
        before { click_button submit }
        let(:player) { Player.find_by_email('player@example.com') }
        it { should have_selector 'title', text: player.name }
        it { should have_selector 'div.alert.alert-success', text: 'Welcome' }
      end
    end
  end

  describe 'profile' do
    let(:player) { FactoryGirl.create :player }
    before { visit player_path(player) }

    it { should have_selector 'h1', text: player.name }
    it { should have_selector 'title', text: player.name }
  end
end
