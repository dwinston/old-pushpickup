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
        it { should have_link 'Sign out' }
      end
    end
  end

  describe 'profile' do
    let(:player) { FactoryGirl.create :player }
    before { visit player_path(player) }

    it { should have_selector 'h1', text: player.name }
    it { should have_selector 'title', text: player.name }
  end

  describe 'edit' do
    let(:player) { FactoryGirl.create(:player) }
    before do 
      sign_in player
      visit edit_player_path(player)
    end

    describe 'page' do
      it { should have_selector 'h1', text: 'Update your profile' }
      it { should have_selector 'title', text: 'Edit player' }
      it { should have_link 'change', href: 'http://gravatar.com/emails' } 
    end

    describe 'with invalid information' do
      before { click_button 'Save changes' }
      it { should have_content 'error' }
    end

    describe 'with valid information' do
      let(:new_name) { 'New Name' }
      let(:new_email) { 'new@example.com' }
      before do
        fill_in 'Name',             with: new_name
        fill_in 'Email',            with: new_email
        fill_in 'Password',         with: player.password
        fill_in 'Confirm password', with: player.password
        click_button 'Save changes'
      end

      it { should have_selector 'title', text: new_name }
      it { should have_selector 'div.alert.alert-success' }
      it { should have_link 'Sign out', href: signout_path }
      specify { player.reload.name.should == new_name }
      specify { player.reload.email.should == new_email }
    end
  end

  describe 'index' do
    before do
      sign_in FactoryGirl.create(:player)
      FactoryGirl.create(:player, name: 'Bob', email: 'bob@example.com')
      FactoryGirl.create(:player, name: 'Ben', email: 'ben@example.com')
      visit players_path
    end

    it { should have_selector 'title', text: 'All players' }
    it { should have_selector 'h1',    text: 'All players' }

    it 'should list each player' do
      Player.all.each do |player|
        page.should have_selector 'li', text: player.name
      end
    end
  end
end
