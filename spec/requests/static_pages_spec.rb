require 'spec_helper'

describe "StaticPages" do

  subject { page }
  
  describe "Home page" do
    before { visit root_path }
    it { should have_selector 'h1', text: 'Push Pickup' }
    it { should have_selector 'title', text: full_title('') }
  end 
  
  describe "Help page" do
    before { visit help_path }
    it { should have_selector 'h1', text: 'Help' }
    it { should have_selector 'title', text: full_title('Help') }
  end

  describe "About page" do
    before { visit about_path }
    it { should have_selector 'h1', text: 'About Us' }
    it { should have_selector 'title', text: full_title('About Us') }
  end

end
