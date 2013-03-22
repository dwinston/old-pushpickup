class AvailabilityObserver < ActiveRecord::Observer
  def after_save(availability)
    create_games(availability)
  end

  def timeslot_intersection(ts1, ts2, options = {})
    end_time   = [ts1[:end_time], ts2[:end_time]].min 
    start_time = [ts1[:start_time], ts2[:start_time]].max
    min_overlap = options[:min_overlap] ? options[:min_overlap] : Float::EPSILON 
    (((end_time - start_time) / 60) >= min_overlap) && {start_time: start_time, end_time: end_time}
  end
  
  # returns an Array of 0 or 1 or 2 timeslots
  def timeslot_difference(ts1, ts2) # ts1 minus ts2
    # six possibilities: 
    #   |*|    | *|     ||    |*   *|    |* |     |*|     # ts1                                     
    # ||      | |      |  |     | |        | |       ||   # ts2     
    start_before = ts2[:start_time] < ts1[:start_time]
    start_during = ts2[:start_time] >= ts1[:start_time] && ts2[:start_time] < ts1[:end_time]
    start_after  = ts2[:start_time] >= ts1[:end_time]
    end_before   = ts2[:end_time] < ts1[:start_time]
    end_during   = ts2[:end_time] >= ts1[:start_time] && ts2[:end_time] < ts1[:end_time]
    end_after    = ts2[:end_time] >= ts1[:end_time]
    
    # I don't need end_after, but I feel its use makes the code easier to read.
    start_before && end_before && [ts1] ||
      start_before && end_during && [{start_time: ts2[:end_time], end_time: ts1[:end_time]}] ||
      start_before && end_after && [] ||
      start_during && end_during && 
        [{start_time: ts1[:start_time], end_time: ts2[:start_time]}, {start_time: ts2[:end_time], end_time: ts1[:end_time]}] ||
      start_during && end_after && [{start_time: ts1[:start_time], end_time: ts2[:start_time]}] ||
      start_after && end_after && [ts1] ||
      raise("unidentified case encountered")
  end

  # An existing game presents an insurmountable conflict if a player would be in two games at the same time
  def conflicting_game(candidate, common)
    candidate_timeslot = {start_time: candidate.start_time, end_time: candidate.start_time.advance(minutes: candidate.duration)}
    candidate.player.games.any? do |game| 
      game_timeslot = {start_time: game.start_time, end_time: game.start_time.advance(minutes: game.duration)}
      unconflicted = timeslot_difference(common[:timeslot], game_timeslot)
      unconflicted.none? { |ts| timeslot_intersection(ts, candidate_timeslot, min_overlap: common[:min_duration]) }
    end
  end

  def satisfies_player_needs(player, common)
    player.needs.all? { |need| need.send(need.name, need.value, common) }
  end

  def evaluate_candidate(candidate, common)
    start_time = candidate.start_time
    end_time = start_time.advance(minutes: candidate.duration)
    min_duration = [common[:min_duration], candidate.player.min_duration_of_game.value].max
    min_players = [common[:min_players], candidate.player.min_players_in_game.value].max
    # a falsy timeslot indicates that candidate cannot join a game given common needs
    timeslot = !conflicting_game(candidate, common) &&
      satisfies_player_needs(candidate.player, common) &&
      timeslot_intersection(common[:timeslot], {start_time: start_time, end_time: end_time}, min_overlap: min_duration)
    {timeslot: timeslot, min_duration: min_duration, min_players: min_players}
  end

  def make_game(compatibles, candidates, common)
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
    my_min_duration = availability.player.min_duration_of_game.value
    my_min_players = availability.player.min_players_in_game.value

    # I can use field.fieldslots instead of field.availabilities because
    # each fieldslot is tied to one and only one field.
    # Even better, I can replace this availability_observer with a fieldslot_observer
    availability.fields.each do |field|
      common = {timeslot: {start_time: my_start_time, end_time: my_end_time},
                min_players: my_min_players, min_duration: my_min_duration, field: field}
      begin 
        # discard cached field.availabilities and reload from database
        candidates = field.availabilities(true).select do |a| 
          a.duration >= my_min_duration && 
            timeslot_intersection(common[:timeslot],
                                  {start_time: a.start_time, end_time: a.start_time.advance(minutes: a.duration)},
                                  min_overlap: [my_min_duration, a.player.min_duration_of_game.value].max)
        end.shuffle!
        made_game = (candidates.count >= my_min_players) && make_game([], candidates, common)
      end while made_game

      # join existing games if possible
      field.games.each do |game|
        game_timeslot = {start_time: game.start_time, end_time: game.start_time.advance(minutes: game.duration)}
        common = {timeslot: game_timeslot, min_players: game.players.count, min_duration: game.duration, field: field} 
        (game.duration >= my_min_duration) && 
          (game.players.count >= my_min_players - 1) &&
          timeslot_intersection({start_time: my_start_time, end_time: my_end_time}, game_timeslot, min_overlap: my_min_duration) &&
          satisfies_player_needs(availability.player, common) && 
          !conflicting_game(availability, common) && 
          game.players << availability.player
      end
    end
  end
end
