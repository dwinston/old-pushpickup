# == Schema Information
#
# Table name: availabilities
#
#  id         :integer          not null, primary key
#  start_time :datetime
#  player_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  duration   :integer
#

require 'spec_helper'

describe Availability do

  let(:player) { FactoryGirl.create(:player) }
  let(:now) { DateTime.now }
  let(:availability) { FactoryGirl.create(:availability, player: player) }
  subject { availability }

  it { should respond_to :start_time }
  it { should respond_to :duration }
  it { should respond_to :player }
  it { should respond_to :fields }
  its(:player) { should == player }

  it { should be_valid }

  describe 'accessible attributes' do
    it 'should not allow access to player_id' do
      expect do
        Availability.new(player_id: player.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe 'when player_id is not present' do
    before { availability.player_id = nil }
    it { should_not be_valid }
  end

  describe 'with start_time in the past (one hour)' do
    before { availability.start_time = now.advance(hours: -1) }
    it { should_not be_valid }
  end

  describe 'with start_time in the distant future (two weeks)' do
    before { availability.start_time = now.advance(days: 15) }
    it { should_not be_valid }
  end

  describe 'with duration that is too long (one day)' do
    before { availability.duration = 24 * 60 }
    it { should_not be_valid }
  end

  describe 'with no fields present' do
    before { availability.fields = [] }
    it { should_not be_valid }
  end
end
