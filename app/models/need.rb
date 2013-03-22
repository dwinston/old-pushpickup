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

class Need < ActiveRecord::Base
  attr_accessible :name, :value
  belongs_to :player

  validates_presence_of :name
  validates_uniqueness_of :name, scope: :player_id

  def min_players_in_game(value, common)
    [common[:min_players], value].max
  end

  def min_duration_of_game(value, common)
    [common[:min_duration], value].max
  end

  def days_separating_games(value, common)
    other_game_day = common[:timeslot][:start_time].to_date
    self.player.games.all? do |game|
      my_game_day = game.start_time.to_date
      (my_game_day + value <= other_game_day) || (my_game_day - value >= other_game_day)
    end
  end
end
