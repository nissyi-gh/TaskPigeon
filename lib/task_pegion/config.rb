# frozen_string_literal: true

class TimePegion
  class Config
    attr_reader :task_types

    def initialize
      @task_types = []
    end
  end
end
