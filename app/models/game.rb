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

class Game < ActiveRecord::Base
  attr_accessible :duration, :start_time, :player_ids
  belongs_to :field
  has_and_belongs_to_many :players

  default_scope order: 'games.start_time ASC'
end
