# == Schema Information
#
#  id         :integer          not null, primary key
#  start_time :datetime
#  duration   :integer
#  field_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Game do

  let(:field) { FactoryGirl.create(:field) }
  let(:soon) { DateTime.now.advance(hours: 3).beginning_of_hour }
  let(:player) { FactoryGirl.create(:player) }
  let(:default_min_duration_of_game) { player.min_duration_of_game.value }
  let(:duration) { 120 }
  let(:game) do
    14.times { FactoryGirl.create(:availability, start_time: soon, duration: duration, fields: [field]) }
    Game.first
  end

  subject { game }

  it { should respond_to :start_time }
  it { should respond_to :duration }
  it { should respond_to :field }
  it { should respond_to :players }

  it { should be_valid }

  its(:duration) { should == default_min_duration_of_game }

  context 'when a game is on' do

    it 'then a new game is not created when only one additional player adds an overlapping availability' do
      expect { FactoryGirl.create(:availability, start_time: soon, duration: duration, fields: [field]) }.not_to change(Game, :count)
    end

    describe "and a new availability encompasses the game" do
      before { FactoryGirl.create(:availability, start_time: soon, duration: duration, fields: [field]) }
        
      its('players.count') { should == 15 }
    end

    describe "and new availabilities overlap but do not encompass the game" do
      before do
        FactoryGirl.create(:availability, start_time: soon, duration: game.duration - 15, fields: [field])
        FactoryGirl.create(:availability, start_time: soon.advance(minutes: 15), duration: game.duration, fields: [field])
      end
        
      its('players.count') { should == 14 }
    end
  end
end
