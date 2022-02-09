# we also can use https://dry-rb.org/gems/dry-struct/1.0/ rather than ruby class

# i think i don't need to test this class for this exercise

class EventEntity
  attr_accessor :id, :station_name, :time

  def initialize(args)
    @id           = args[:id]
    @station_name = args[:station_name]
    @time         = args[:time]
  end
end
