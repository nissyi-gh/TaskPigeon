# frozen_string_literal: true

class TimePegion
  class Record
    attr_reader :id
    attr_accessor :task_type, :started_at, :ended_at

    def initialize(id)
      @id = id
    end
  end
end
