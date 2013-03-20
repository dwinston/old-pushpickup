module ApplicationHelper

  def full_title(page_title)
    base_title = "Push Pickup"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def start_time_to_s(start_time)
    Time.zone = 'America/Los_Angeles'
    start_time.in_time_zone.strftime("%A, %B #{start_time.day.ordinalize}, %I:%M%p")
  end

  def duration_to_s(start_time, duration)
    distance_of_time_in_words(start_time, start_time.advance(minutes: duration))
  end
end
