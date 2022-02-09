# we also can use https://dry-rb.org/gems/dry-struct/1.0/ rather than ruby class

class AverageEntity
  attr_accessor :id, :total_time, :count

  def initialize(args)
    @id           = args[:id]
    @total_time   = args[:total_time]
    @count        = args[:count] || 1
  end

  def average_time
    (total_time / count.to_f)
  end
end
