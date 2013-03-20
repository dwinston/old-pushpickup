# == Schema Information
#
# Table name: games
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

  let(:game) { FactoryGirl.create(:game) }
  let(:player) { FactoryGirl.create(:player) }
  let(:field) { FactoryGirl.create(:field) }
  let(:soon) { DateTime.now.advance(hours: 3).beginning_of_hour }

  subject { game }

  it { should respond_to :start_time }
  it { should respond_to :duration }
  it { should respond_to :field }
  it { should respond_to :players }

  it { should be_valid }

  describe 'player availabilities create a game' do
    before do
      13.times { FactoryGirl.create(:availability, start_time: soon, fields: [field]) }
      FactoryGirl.create(:availability, player: player, start_time: soon, fields: [field])
    end

    it 'but a new game should not be created when only one additional player adds an overlapping availability' do
      expect { FactoryGirl.create(:availability, start_time: soon, fields: [field]) }.not_to change(Game, :count)
    end

    subject { player.games.first }

    describe "a player has an availability that overlaps with the game" do
      before { FactoryGirl.create(:availability, start_time: soon, fields: [field]) }
        
      its('players.count') { should == 15 }
    end
  end
end
