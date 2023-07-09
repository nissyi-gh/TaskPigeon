# frozen_string_literal: true

module TaskPegion
  class Record
    attr_reader :id
    attr_accessor :task_type, :started_at, :ended_at

    def initialize(id: 1, task_type: 'Other', started_at: Time.now, ended_at: nil)
      @id = id
      @task_type = task_type
      @started_at = started_at
      @ended_at = ended_at
    end
  end
end
