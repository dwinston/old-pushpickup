# == Schema Information
#
# Table name: needs
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  player_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  value      :integer
#

require 'spec_helper'

describe Need do

  let(:player) { FactoryGirl.create(:player) }

  subject { player.needs.sample }

  it { should respond_to :name }
  it { should respond_to :value }
  it { should respond_to :player }
  its(:player) { should == player }

  it { should be_valid }
  
  it 'all needs must be registered' do
    player.needs.all?{ |n| player.registered_need_names.include? n.name.to_sym }.should be_true
  end

  let(:default_min_players_in_game) { player.min_players_in_game.value } 
  let(:default_min_duration_of_game) { player.min_duration_of_game.value } 
  let(:default_min_days_separating_games) { player.min_days_separating_games.value } 
  let(:start_time) { DateTime.now.advance(days: 2).beginning_of_hour }
  let(:duration) { 45 }
  let(:field) { FactoryGirl.create(:field) }

  describe 'when need one more player for game' do
    before do 
      (default_min_players_in_game - 1).times do
        FactoryGirl.create(:availability, start_time: start_time, duration: duration, fields: [field])
      end
    end

    it 'then player should by default join after creating a compatible availability' do
      expect do 
        FactoryGirl.create(:availability, player: player, start_time: start_time, duration: duration, fields: [field])
      end.to change(Game, :count).by(1)
    end

    describe 'and player requires one more than the default number of players in a game' do
      before { player.min_players_in_game = default_min_players_in_game + 1 }

      it 'then player should not help create the game yet' do
        expect do 
          FactoryGirl.create(:availability, player: player, start_time: start_time, duration: duration, fields: [field])
        end.not_to change(Game, :count).by(1)
      end
    end

    describe 'and player requires the game be longer in duration than is currently possible' do
      before { player.min_duration_of_game = default_min_duration_of_game + 45 }

      it 'then player should not help create the game yet' do
        expect do 
          FactoryGirl.create(:availability, player: player, start_time: start_time, 
                             duration: player.min_duration_of_game.value, fields: [field])
        end.not_to change(Game, :count).by(1)
      end
    end

    describe "and need one more player for game default_min_days_separating_games days away" do
      before do 
        (default_min_players_in_game - 1).times do
          FactoryGirl.create(:availability, start_time: start_time.advance(days: default_min_days_separating_games), 
                             duration: duration, fields: [field])
        end
      end

      it 'then player should by default create two games after creating overlapping availabilities' do
        expect do 
          FactoryGirl.create(:availability, player: player, start_time: start_time, duration: duration, fields: [field])
          FactoryGirl.create(:availability, player: player, start_time: start_time.advance(days: default_min_days_separating_games), 
                             duration: duration, fields: [field])
        end.to change(Game, :count).by(2)
      end

      describe 'and player requires her games to have more days between them than default' do
        before { player.min_days_separating_games = default_min_days_separating_games + 1 }

        it 'then player should create only one game after creating overlapping availabilities' do
          expect do 
            FactoryGirl.create(:availability, player: player, start_time: start_time, duration: duration, fields: [field])
            FactoryGirl.create(:availability, player: player, start_time: start_time.advance(days: default_min_days_separating_games), 
                               duration: duration, fields: [field])
          end.to change(Game, :count).by(1)
        end
      end
    end
  end
end

