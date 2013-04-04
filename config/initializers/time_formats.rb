Time::DATE_FORMATS[:weekday_and_ordinal] = ->(time) { time.strftime("%A, %B #{time.day.ordinalize}, %I:%M%p") }
