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

  validates :start_time, presence: true
  validate :start_time_between_now_and_two_weeks_from_now
  validate :duration_under_one_day
  validates :player_id, presence: true
  default_scope order: 'availabilities.start_time ASC'

  def start_time_to_s
    start_time.strftime("%A, %B #{start_time.day.ordinalize}, %I:%M%p")
  end

  def duration_to_s
    distance_of_time_in_words(start_time, start_time.advance(minutes: duration))
  end

  private

    def duration_under_one_day
      errors.add(:duration, 'must be under one day') unless duration < 24 * 60
    end

    def start_time_between_now_and_two_weeks_from_now
      now = DateTime.now
      if ((start_time < now) || (start_time > now.advance(weeks: 2)))
        errors.add(:start_time, 'must be between now and two weeks from now')
      end
    end
end
