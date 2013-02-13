require 'spec_helper'

describe "StaticPages" do

  subject { page }
  let(:base_title) { 'Push Pickup' }
  
  describe "Home page" do
    before { visit '/static_pages/home' }
    it { should have_selector 'h1', text: 'Push Pickup' }
    it { should have_selector 'title', text: base_title }
  end 
  
  describe "Help page" do
    before { visit '/static_pages/help' }
    it { should have_selector 'h1', text: 'Help' }
    it { should have_selector 'title', text: "#{base_title} | Help" }
  end

  describe "About page" do
    before { visit '/static_pages/about' }
    it { should have_selector 'h1', text: 'About Us' }
    it { should have_selector 'title', text: "#{base_title} | About Us" }
  end

end
