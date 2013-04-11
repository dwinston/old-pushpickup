# == Schema Information
#
# Table name: fieldslots
#
#  id              :integer          not null, primary key
#  availability_id :integer
#  field_id        :integer
#  open            :boolean          default(TRUE)
#  why_not_open    :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'spec_helper'

describe Fieldslot do

  let(:player) { FactoryGirl.create :player }
  let(:field) { FactoryGirl.create :field }
  let(:sooner) { Time.zone.now.beginning_of_hour + 2.hours }
  let(:availability) { FactoryGirl.create :availability, start_time: sooner, player: player, fields: [field] }
  let(:fieldslot) { FactoryGirl.create :closed_fieldslot, field: field, availability: availability }

  subject { fieldslot }

  it { should respond_to :field }
  it { should respond_to :availability }
  it { should respond_to :open }
  it { should respond_to :why_not_open }

  it { should_not be_open }
  its(:field) { should == field }
  its('availability.fields') { should include field }

  describe 'when a closed fieldslot' do
    let(:later) { Time.zone.now.beginning_of_hour + 1.day }
    let(:long_duration) { 120 }
    before do
      FactoryGirl.create(:unavailability, fields: [field], start_time: later, duration: long_duration)
    end
    
    describe 'does not overlaps a potential game' do
      before do 
        14.times { FactoryGirl.create(:availability, fields: [field], start_time: later - 12.hours, duration: long_duration) }
      end

      subject { field.games.last }
      its(:start_time) { should == later - 12.hours }
    end

    describe 'overlaps a potential game, but not so much as to prevent creating a game beforehand' do
      before do 
        14.times { FactoryGirl.create(:availability, fields: [field], start_time: later - 1.hour, duration: long_duration) }
      end

      subject { field.games.last }
      its(:start_time) { should == later - 1.hour }
    end

    describe 'overlaps a potential game, but not so much as to prevent creating a game afterwards' do
      before do
        14.times do
          FactoryGirl.create(:availability, fields: [field], start_time: later + long_duration.minutes - 1.hour, duration: long_duration)
        end
      end

      subject { field.games.last }
      its(:start_time) { should == later + long_duration.minutes }
    end

    describe 'overlaps a potential game, enough to prevent creating a game' do
      before do
        14.times do
          FactoryGirl.create(:availability, fields: [field], start_time: later - 15.minutes, duration: long_duration)
        end
      end

      subject { field.games.last }
      it { should be_nil }
    end
  end
end
