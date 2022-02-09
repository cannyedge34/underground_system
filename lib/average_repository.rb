require './lib/in_memory/average'
require './lib/average_entity'

class AverageRepository
  # we can use any implementation/adapter with this port/interface, changing data_source param

  def initialize(data_source: ::InMemory::Average.new)
    @data_source = data_source
  end

  def all
    data_source.all.map { |average| ::AverageEntity.new(average) }
  end

  def find(id)
    # repositories shoud not raise exceptions. It would be a different layer where
    # we should check if returned value of repository is nil/empty entity
    # this layer could raise the exception, not here.

    # we return null-object/empty if record is not found
    ::AverageEntity.new(data_source.find(id) || {})
  end

  def create(data)
    ::AverageEntity.new(data_source.create(data))
  end

  def update(data)
    ::AverageEntity.new(data_source.update(data))
  end

  def save(data)
    guaranteed_average = find(data[:id])

    # maybe i should think how to avoid this condition/guard clausule.
    return create(id: data[:id], total_time: data[:total_time]) unless guaranteed_average.id

    update(
      id: data[:id],
      total_time: guaranteed_average.total_time += data[:total_time],
      count: guaranteed_average.count += 1
    )
  end

  private

  attr_reader :data_source
end
