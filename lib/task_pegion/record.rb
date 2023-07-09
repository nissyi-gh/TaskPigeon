# frozen_string_literal: true

module TaskPegion
  class Record
    require 'csv'

    attr_reader :id
    attr_accessor :task_type, :task_name, :started_at, :ended_at

    def initialize(id: new_id, task_type: 'Other', task_name: nil, started_at: Time.now, ended_at: nil)
      @id = id
      @task_type = task_type
      @task_name = task_name
      @started_at = started_at
      @ended_at = ended_at
    end

    def save
      CSV.open('records.csv', 'a') do |csv|
        csv << [id, task_type, task_name, started_at, ended_at]
      end
    end

    def self.last
      row = CSV.read('records.csv').last
      new(id: row[0], task_type: row[1], task_name: row[2], started_at: row[3], ended_at: row[4])
    end

    private

    def new_id
      CSV.read('records.csv').size
    end
  end
end
