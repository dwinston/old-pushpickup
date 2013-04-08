require 'spec_helper'

describe "StaticPages" do

  subject { page }
  
  shared_examples_for "all static pages" do
    it { should have_selector 'h1', text: heading }
    it { should have_selector 'title', text: full_title(page_title) }
  end
  
  describe "Home page" do
    before { visit root_path }
    let(:heading) { 'Push Pickup' }
    let(:page_title) { '' }
    it_should_behave_like "all static pages"

    describe 'for signed-in players' do
      let(:player) { FactoryGirl.create(:player) }
      let(:field) { FactoryGirl.create(:field) }
      let(:soonest) { DateTime.now.advance(hours: 1).beginning_of_hour }
      before do
        FactoryGirl.create(:availability, player: player, 
                           start_time: soonest, fields: [field])
        FactoryGirl.create(:availability, player: player, 
                           start_time: soonest.advance(days: 1))
        sign_in player
        visit root_path
      end

      it "should render the player's availability feed" do
        player.availability_feed.each do |item|
          page.should have_selector "li#availability_#{item.id}", text: item.start_time_to_s
        end
      end

      it "should render the player's games feed" do
        player.game_feed.each do |item|
          page.should have_selector "li#game_#{item.id}", text: start_time_to_s(item.start_time)
        end
      end

      describe "with an upcoming game" do
        before do
          13.times { FactoryGirl.create(:availability, start_time: soonest, fields: [field]) }
          visit root_path
        end

        it "game should be created" do
          field.games.count.should == 1
        end
        it { should have_content "GAME ON at #{field.name}" }
      end
    end
  end 
  
  describe "Help page" do
    before { visit help_path }
    let(:heading) { 'Help' }
    let(:page_title) { 'Help' }
    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before { visit about_path }
    let(:heading) { 'About Us' }
    let(:page_title) { 'About Us' }
    it_should_behave_like "all static pages"
  end

  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    page.should have_selector 'title', text: full_title('About Us')
    click_link "Help"
    page.should have_selector 'title', text: full_title('Help')
    click_link "Home"
    click_link "Sign up now!"
    page.should have_selector 'title', text: full_title('Sign up')
    click_link "push pickup"
    page.should have_selector 'title', text: full_title('')
    click_link "Fields"
    page.should have_selector 'title', text: full_title('Fields')
  end

end
