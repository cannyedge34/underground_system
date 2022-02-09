# i think i don't need to test this implementation example for this exercise

module InMemory
  class Event
    def initialize
      @records = []
    end

    def all
      @records
    end

    def find(id)
      records.find { |record| record[:id] == id }
    end

    def create(record)
      records << record
      record
    end

    def delete(id)
      record = find(id)
      records.delete(record)
    end

    private

    attr_reader :records
  end
end
