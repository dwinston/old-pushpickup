Time::DATE_FORMATS[:weekday_and_ordinal] = ->(time) { time.strftime("%A, %B #{time.day.ordinalize}, %I:%M%P") }
Time::DATE_FORMATS[:weekday] = "%A"
Date::DATE_FORMATS[:weekday] = "%A"
Time::DATE_FORMATS[:tiny_ordinal] = ->(time) { time.strftime("%b #{time.day.ordinalize}") }
Date::DATE_FORMATS[:tiny_ordinal] = ->(time) { time.strftime("%b #{time.day.ordinalize}") }
Time::DATE_FORMATS[:ampm_time] = "%l:%M%P"

class ActiveSupport::TimeWithZone
  def succ
    self + 15.minutes
  end
end
