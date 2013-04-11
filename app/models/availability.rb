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
  attr_accessible :field_ids, :day, :hour_and_minute, :duration_in_sec #, :start_time, :duration
  attr_accessor :adding_fields
  attr_reader :day, :hour_and_minute, :duration_in_sec
  belongs_to :player
  has_many :fieldslots, dependent: :destroy
  has_many :fields, through: :fieldslots

  before_validation :save_start_time
  
  validate :start_time_in_future
  validate :start_time_in_coming_week
  validates :duration, numericality: { only_integer: true, 
    less_than: 24 * 60, message: 'must be fewer than 24 hours'}
  validates :player_id, presence: true
  validate :at_least_one_field, unless: :adding_fields

  default_scope order: 'availabilities.start_time ASC'
  scope :future, lambda { where("start_time > ?", Time.zone.now) }

  def unavailability?
    !fieldslots.first.open
  end

  def day=(beginning_of_day)
    @day = Time.zone.parse(beginning_of_day)
  end

  def hour_and_minute=(h_and_m)
    @hour_and_minute = Time.zone.parse(h_and_m)
  end

  def duration_in_sec=(number)
    @duration_in_sec = number.to_i
    self.duration = (@duration_in_sec / 60).round
  end

  def save_start_time
    self.start_time = @day + @hour_and_minute.hour.hours + @hour_and_minute.min.minutes if @day.present? && @hour_and_minute.present?
  end

  def start_day_options
    today = soonest_start_time.beginning_of_day
    days = (0..7).map{|n| today + n.days}
    day_labels = days.each_with_index.map do |day, index| 
      label = day.to_s(:weekday)
      if index == 0
        label += " (today)"
      elsif index == 1
        label += " (tomorrow)"
      elsif index == days.count - 1
        label = label + " (" + day.to_s(:tiny_ordinal) + ")"
      end
      label
    end
    day_labels.zip(days)
  end

  def start_hour_and_minute_options
    first_option = soonest_start_time
    # now.all_day appears to ignore config.time_zone, so instead I do this.
    all_day = (first_option.beginning_of_day)...(first_option.end_of_day) 
    all_day.map{|t| t.to_s(:ampm_time)}.zip(all_day)
  end

  def soonest_start_time
    now = Time.zone.now
    possible = now.beginning_of_hour + 15.minutes
    (possible..(possible + 1.hour)).detect{|t| t > 5.minutes.from_now}
  end

  def duration_options
    now = Time.zone.now
    distant_times = (now + 45.minutes)..(now + 6.hours)
    durations = distant_times.map{|t| (t - now).to_i}
    distant_times.map{|t| distance_of_time_in_words(now, t)}.zip(durations)
  end
  
  private

    def at_least_one_field
      errors.add(:base, 'Availability must include at least one Field') if self.fields.blank?
    end

    def start_time_in_future
      errors.add(:base, 'It is currently not possible to play in the past') if self.start_time < soonest_start_time
    end

    def start_time_in_coming_week
      soonest = soonest_start_time
      time_range = soonest..(soonest.end_of_day + 7.days)
      errors.add(:base, 'Your availability must be in the coming week') if !time_range.include?(self.start_time)
    end

end
