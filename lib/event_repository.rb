require './lib/in_memory/event'
require './lib/event_entity'

class EventRepository
  # we can use any implementation/adapter with this port/interface, changing data_source param

  def initialize(data_source: ::InMemory::Event.new)
    @data_source = data_source
  end

  def all
    # By nature, a repository will instantiate entities/aggregates.
    # From infrastructure we call the domain layer. This is (coupling).
    # we are going to instantiate a EventEntity.new in the infrastructure layer.
    # This coupling is assumed and is not as serious/dangerous as
    # if something in the domain layer depended on something in the infrastructure layer.
    data_source.all.map { |event| ::EventEntity.new(event) }
  end

  def save(data)
    ::EventEntity.new(data_source.create(data))
  end

  def find(id)
    ::EventEntity.new(data_source.find(id) || {})
  end

  def delete(id)
    data_source.delete(id)
  end

  private

  attr_reader :data_source
end
