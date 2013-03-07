require 'spec_helper'

describe "CitiesPages" do

  subject { page }

  let(:admin) { FactoryGirl.create :admin }
  let!(:city) { FactoryGirl.create :city }

  describe 'index' do
    before do
      sign_in admin
      visit cities_path
    end

    it { should have_content city.name }
    it { should have_link 'delete', href: city_path(city) }
    it { should have_link 'Add city', href: new_city_path }

  end
end
