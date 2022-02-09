require './lib/event_repository'
require './lib/average_repository'

# TIME COMPLEXITY: O(1) check_in, check_out and get_average_time methods will be constant.
# just, inserting, looking, removing... No loops.

# SPACE COMPLEXITY: O(N + M)
# N = events that we have. Events is going to grow larger as we get passengers doing check-in but don't check-out.
# because we delete those entries/events in check_out function.
# M = numbers of averages that we have. It's gonna increase the more times the customers checkout
#   that's why we include both n + m

class UndergroundSystem
  # i inject these two repositories (indirection layers)
  # because we don't have any kind of event broker (rabbit, actor model, kafka...etc)
  # to communicate via events these aggregates with each other (in this exercise).
  # With domain-driven-architecture usually, we inject the repository and the event bus in the use_case/application service,
  # we persist the obect in the database and we publish an event from use_case.
  # This UndergroundSystem agregate would have consumers listening the messages (commands/events)
  # emitted by the Event/Average. Messages can be published from Aggregates/Handlers.

  # with event-sourcing, we rebuild the entity state with projections. It means that we don't need to
  # save the entity in db like rails does, it is rehydrated or reconstructed depending on
  # the occurred events in the event database.

  DELIMITER = ','.freeze

  def initialize(event_repository: EventRepository.new, average_repository: AverageRepository.new)
    @event_repository = event_repository
    @average_repository = average_repository
  end

  def check_in(id, station_name, time)
    save_event(id: id, station_name: station_name, time: time)
  end

  def check_out(id, station_name, time)
    event = guaranteed_event(id)
    delete_event(event.id)
    save_average(event: event, station_name: station_name, time: time)
  end

  def get_average_time(start_station, end_station)
    # we would use uuid from frontend.
    # We don't want depend on database adapter/implementation (autoincremental sql id).
    # but i think i can use this format "#{start_station},#{end_station}" in this exercise.
    average_entity = guaranteed_average("#{start_station}#{DELIMITER}#{end_station}")
    average_entity.average_time
  end

  private

  attr_reader :event_repository, :average_repository

  def save_event(id:, station_name:, time:)
    event_repository.save(id: id, station_name: station_name, time: time)
  end

  def delete_event(id)
    event_repository.delete(id)
  end

  def save_average(event:, station_name:, time:)
    average_repository.save(
      id: "#{event.station_name}#{DELIMITER}#{station_name}",
      total_time: time - event.time
    )
  end

  def guaranteed_event(id)
    event_repository.find(id)
  end

  def guaranteed_average(id)
    average_repository.find(id)
  end
end