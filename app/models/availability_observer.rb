class AvailabilityObserver < ActiveRecord::Observer
  def after_save(availability)
    create_games(availability)
  end

  def timeslot_intersection(ts1, ts2, options = {})
    end_time   = [ts1[:end_time], ts2[:end_time]].min 
    start_time = [ts1[:start_time], ts2[:start_time]].max
    min_overlap = options[:min_overlap] ? options[:min_overlap] : 0
    (((end_time - start_time) / 60).round > min_overlap) && {start_time: start_time, end_time: end_time}
  end

  def conflicting_game(player, timeslot)
    player.games.any? do |game| 
      timeslot_intersection(timeslot, 
                            {start_time: game.start_time, end_time: game.start_time.advance(minutes: game.duration)})
    end
  end

  def evaluate_candidate(candidate, common)
    start_time = candidate.start_time
    end_time = start_time.advance(minutes: candidate.duration)
    # TODO: set min_overlap as max of common[:min_duration] and candidate.player.preferences[:min_duration]
    # if it is not nil
    min_overlap = common[:min_duration]
    # TODO: conditionally set :min_players in returned hash if
    # candidate.player.preferences[:min_players] && 
    #   candidate.player.preferences[:min_players] > common[:min_players]
    {timeslot: !conflicting_game(candidate.player, common[:timeslot]) && 
      timeslot_intersection(common[:timeslot], 
                            {start_time: start_time, end_time: end_time}, 
                            min_overlap: min_overlap)}
  end

  def make_game(compatibles, candidates, common = {})
    # below test is for equality because game creation is sought after every single save of an Availability
    if compatibles.count == common[:min_players]
      common[:field].games.create!(
        start_time: common[:timeslot][:start_time],
        duration: ((common[:timeslot][:end_time] - common[:timeslot][:start_time]) / 60).round,
        player_ids: compatibles.map(&:player_id))
    elsif candidates.empty?
      false
    else
      candidate = candidates.pop
      changes_with_candidate = evaluate_candidate(candidate, common)
      new_common = common.merge(changes_with_candidate)
      (new_common[:timeslot] && make_game(compatibles + [candidate], candidates, new_common)) || 
        make_game(compatibles, candidates, common)
    end
  end

  def create_games(availability)
    my_start_time = availability.start_time
    my_end_time = availability.start_time.advance(minutes: availability.duration)
    my_min_duration = 45 # TODO: store as availability.player preference
    my_min_players = 14  # TODO: store as availability.player preference

    # I can use field.fieldslots instead of field.availabilities because
    # each fieldslot is tied to one and only one field.
    # Even better, I can replace this availability_observer with a fieldslot_observer
    availability.fields.each do |field|
      begin 
        # discards any cached copy of field.availabilities and reloads from database
        candidates = field.availabilities(true).select do |a| 
          a.duration >= my_min_duration && 
            timeslot_intersection({start_time: my_start_time, end_time: my_end_time},
                                  {start_time: a.start_time, end_time: a.start_time.advance(minutes: a.duration)},
                                  min_overlap: my_min_duration)
        end.shuffle!.reject{ |a| a == availability }

        made_game = (candidates.count + 1 >= my_min_players) &&  
          make_game([availability], candidates, 
                    timeslot: {start_time: my_start_time, end_time: my_end_time}, 
                    min_players: my_min_players, min_duration: my_min_duration, field: field)
      end while made_game

      # join existing games if possible
      field.games.each do |game|
        game_timeslot = {start_time: game.start_time, end_time: game.start_time.advance(minutes: game.duration)}
        (game.duration >= my_min_duration) && !conflicting_game(availability.player, game_timeslot) && 
          timeslot_intersection({start_time: my_start_time, end_time: my_end_time}, game_timeslot, min_overlap: my_min_duration) &&
          game.players << availability.player
      end
    end
  end
end
