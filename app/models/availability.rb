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
include ActionView::Helpers::DateHelper

class Availability < ActiveRecord::Base
  attr_accessible :start_time, :duration
  belongs_to :player

  valid_times = 
    Enumerator.new do |y|
      dt = DateTime.now.advance(hours: 1).beginning_of_hour 
      loop do
        y << dt
        dt = dt.advance(minutes: 15)
      end
    end.take_while { |dt| dt < 2.weeks.from_now }

  validates :start_time, inclusion: { in: valid_times, 
    message: 'must be between now and two weeks from now, and one of 
    {0, 15, 30, 45} minutes after the hour'}
  validates :duration, numericality: { only_integer: true, 
    less_than: 24 * 60, message: 'must be under one day'}
  validates :player_id, presence: true
  default_scope order: 'availabilities.start_time ASC'

  def start_time_to_s
    Time.zone = 'America/Los_Angeles'
    start_time.in_time_zone.strftime("%A, %B #{start_time.day.ordinalize}, %I:%M%p")
  end

  def duration_to_s
    distance_of_time_in_words(start_time, start_time.advance(minutes: duration))
  end
  
  private

    def start_time_between_now_and_two_weeks_from_now
      now = DateTime.now
      if (start_time.nil? || 
          (start_time < now) || 
          (start_time > now.advance(weeks: 2)))
        errors.add(:start_time, 'must be between now and two weeks from now')
      end
    end

end
