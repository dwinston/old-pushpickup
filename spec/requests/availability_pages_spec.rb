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
        select 'tomorrow'
        select '1:00pm'
        select '2 hours'
        check field.name
      end
      it 'should create an availability' do
        expect { click_button 'Post' }.to change(Availability, :count).by(1)
      end
    end

    describe 'while not activated' do
      before do
        player.toggle!(:activated)
        sign_in player
      end

      describe 'and in trial period' do
        before { submit_availability [field] }

        it { should have_content "currently unable" }
        it { should have_content "Have you confirmed" }
      end

      describe 'and with expired trial period' do
        before do
          player.update_attribute(:created_at, 31.days.ago)
          sign_in player
          submit_availability [field] 
        end

        it { should have_content "currently unable" }
        it { should have_content "consider subscribing" }
      end
    end

    describe 'with enough other players available for a game' do
      let(:later) { soon + 1.day } 

      before do
        13.times { FactoryGirl.create(:availability, start_time: later, fields: [field]) }
        # :availability factory creates fields after :create but not after :build, necessitating
        # the passing of fields as a separate argument to submit_availability
        visit root_path
        submit_availability [field], day: later.to_s(:weekday), time: later.to_s(:ampm_time) 
      end
      it { should have_content "GAME ON at #{field.name}" }
    end

  end

  describe 'unavailability creation' do
    before { visit root_path }

    it { should_not have_content 'Unavailability?' }
    it { should_not have_content 'Why?' }

    describe 'as admin' do
      let(:admin) { FactoryGirl.create(:admin) }
      before do
        sign_in admin
        visit field_path(field) # admin has no availabilities, so no fields are accessible from her root_path
      end

      it { should have_content 'Unavailability?' }
      it { should have_content 'Why?' }

      describe 'with a reason' do
        before do
          check 'Unavailability?'
          fill_in 'Why?', with: 'first amendment overturned'
          submit_availability [field]
        end

        it { should have_content 'Unavailability created' }
      end

      describe 'with enough other players available for a game during the unavailability' do
        before do
          submit_unavailability [field], 'Because I said so', day: soon.to_s(:weekday), time: soon.to_s(:ampm_time) 
          14.times { FactoryGirl.create(:availability, start_time: soon, fields: [field]) }
          visit field_path(field)
        end

        it { should_not have_content "GAME ON at #{field.name}" }
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
