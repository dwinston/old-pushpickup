require 'spec_helper'

describe "AvailabilityPages" do
  subject { page }

  let(:player) { FactoryGirl.create(:player) }
  let(:field) {  FactoryGirl.create(:field) }
  let(:availability) { FactoryGirl.create(:availability, player: player) }
  before do 
    availability.fields = [field]
    sign_in player 
  end

  describe 'availability creation' do
    before { visit root_path }

    describe 'with invalid information' do

      it 'should not create an availability' do
        expect { click_button 'Post' }.not_to change(Availability, :count)
      end

      describe 'error messages' do
        before { click_button 'Post' }
        it { should have_content 'error' }
      end
    end

    describe 'with valid information' do

      before do
        fill_in 'Start time', with: 'this sunday 2pm'
        fill_in 'Duration', with: '2 hours'
        check field.name
      end
      it 'should create an availability' do
        expect { click_button 'Post' }.to change(Availability, :count).by(1)
      end
    end
  end

  describe 'availability destruction' do
    before { FactoryGirl.create(:availability, player: player) }

    describe 'as correct user' do
      before { visit root_path }

      it 'should delete an availability' do
        expect { click_link 'delete' }.to change(Availability, :count).by(-1)
      end
    end

  end
end
