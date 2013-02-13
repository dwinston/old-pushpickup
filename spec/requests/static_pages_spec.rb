require 'spec_helper'

describe "StaticPages" do

  subject { page }
  
  describe "Home page" do
    before { visit '/static_pages/home' }
    it { should have_content 'Push Pickup' }
    it { should have_selector 'title', text: 'Push Pickup | Home' }
  end 
  
  describe "Help page" do
    before { visit '/static_pages/help' }
    it { should have_content 'Help' }
  end

  describe "About page" do
    before { visit '/static_pages/about' }
    it { should have_content 'About Us' }
  end

end
