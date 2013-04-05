require 'spec_helper'

describe "AvailabilityPages" do
  subject { page }

  let(:player) { FactoryGirl.create(:player) }
  let(:field) {  FactoryGirl.create(:field) }
  let(:soon) { Time.zone.now.beginning_of_hour + 3.hours }
  let!(:availability) { FactoryGirl.create(:availability, player: player, 
                                          start_time: soon, fields: [field]) }
  before { sign_in player }

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

    #describe 'while not activated' do
    #  let!(:inactive_player) { FactoryGirl.create(:player, name: 'Argon', activated: false) }

    #  before do
    #    sign_in inactive_player
    #    submit_availability FactoryGirl.build(:availability, start_time: soon), [field]
    #  end

    #  it { should have_content "currently unable" }
    #end

    describe 'with enough other players available for a game' do
      let(:later) { soon + 1.day } 

      before do
        13.times { FactoryGirl.create(:availability, start_time: later, fields: [field]) }
        # :availability factory creates fields after :create but not after :build, necessitating
        # the passing of fields as a separate argument to submit_availability
        submit_availability FactoryGirl.build(:availability, start_time: later), [field]
      end
      it { should have_content "GAME ON at #{field.name}" }
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
