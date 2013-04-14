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
    value
  end

  def min_duration_of_game(value, common)
    value
  end

  def min_days_separating_games(value, common)
    other_game_day = common[:timeslot][:start_time].to_date
    player.games.all? do |game|
      my_game_day = game.start_time.to_date
      (my_game_day + value <= other_game_day) || (my_game_day - value >= other_game_day)
    end
  end

  def pretty_name
    result = name.gsub(/^(?:(?:min)|(?:max))_/, '')
    case name
    when /^min_[a-z]+s/
      result = 'Minimum number of ' + result
    when /^min_/
      result = 'Minimum ' + result
    when /^max_[a-z]+s/
      result = 'Maximum number of ' + result
    when /^max_/
      result = 'Maximum ' + result
    else
      result = result.capitalize
    end
    result.gsub('_',' ')
  end

  def options_for_select
    case name
    when /^min_players_in_game/
      (6..14).reject{|n| n % 2 == 1}
    when /^min_duration_of_game/
      ['30 minutes', '45 minutes', '1 hour'].zip([30,45,60])
    when /^min_days_separating_games/
      ['0 (same day OK)'].concat((1..7).to_a).zip(0..7)
    else
      ['yes','no'].zip([0,1])
    end
  end
end
