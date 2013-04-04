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
        fill_in 'Confirm password', with: 'foobar'
      end

      it 'should create player' do
        expect { click_button submit }.to change(Player, :count).by(1)
      end

      describe 'after saving player' do
        before { click_button submit }

        let(:player) { Player.find_by_email('player@example.com') }

        it { should have_content "Email sent" }
        it { should_not have_link 'Sign out' }
        it "emails player to confirm email address" do
          last_email.to.should include(player.email)
        end

        describe "should not be able to sign in yet" do
          before { sign_in player }
          
          it { should_not have_link 'Sign out' }
        end
        
        describe "after confirming player's email address" do
          before { visit signup_confirmation_path(player.remember_token) }  
          it { should have_content player.name }
          it { should have_selector 'div.alert.alert-success', text: 'Welcome' }
          it { should have_link 'Sign out' }
        end
      end
    end
  end

  describe 'home page after sign-in' do
    let(:player) { FactoryGirl.create :player }
    let(:sooner) { DateTime.now.advance(days: 1).beginning_of_hour }
    let(:later) { sooner.advance(days: 1) }
    let!(:a1) { FactoryGirl.create(:availability, player: player, start_time: sooner) }
    let!(:a2) { FactoryGirl.create(:availability, player: player, start_time: later) }

    before do
      sign_in player
      visit root_url
    end

    it { should have_content player.name }

    describe 'availabilities' do
      it { should have_content a1.start_time_to_s }
      it { should have_content a2.start_time_to_s }
      it { should have_content player.availabilities.count }

      describe 'should not show if in past' do
        before do
          a1.start_time = 2.days.ago.beginning_of_hour
          a1.save(validate: false)
          visit player_path(player)
        end
        it { should_not have_content a1.start_time_to_s }
        it { should have_content a2.start_time_to_s }
      end
    end
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
      
      it { should have_content new_name }
      it { should have_selector 'div.alert.alert-success' }
      it { should have_link 'Sign out', href: signout_path }
      specify { player.reload.name.should == new_name }
      specify { player.reload.email.should == new_email }
    end
  end

  describe 'index' do

  let(:admin) { FactoryGirl.create :admin }

    before(:each) do
      sign_in admin
      visit players_path
    end

    it { should have_selector 'title', text: 'All players' }
    it { should have_selector 'h1',    text: 'All players' }

    describe 'pagination' do

      before(:all) { 30.times { FactoryGirl.create(:player) } }
      after(:all) { Player.delete_all }

      it { should have_selector 'div.pagination' }

      it 'should list each player' do
        Player.paginate(page: 1).each do |player|
          page.should have_selector 'li', text: player.name
        end
      end
    end

    describe 'delete links' do

      # Currently, only admin users can access Players index.
      #it { should_not have_link 'delete' }

      describe 'as an admin user' do
        let!(:player) { FactoryGirl.create(:player) }
        before do
          sign_in admin
          visit players_path
        end

        it { should have_link 'delete', href: player_path(Player.last) }
        it "should be able to delete another player" do
          expect { click_link 'delete' }.to change(Player, :count).by(-1)
        end
        it { should_not have_link 'delete', href: player_path(admin) }
      end
    end
  end
end
